function affinities=getAffinityForDiscreteRateTasks(mdl)




    [~,periods,~]=soc.internal.getDiscreteRatesInfoFromModel(mdl);
    affinities=zeros(1,numel(periods));
    mgr=soc.internal.connectivity.getTaskManagerBlock(mdl);
    if~isempty(mgr)
        affinities=locUpdateAffinityFromTaskManager(mdl,mgr,periods,affinities);
    end
end


function affinities=locUpdateAffinityFromTaskManager(mdl,mgr,periods,affinities)
    allTaskData=get_param(mgr,'AllTaskData');
    dm=soc.internal.TaskManagerData(allTaskData,'evaluate',mdl);
    allTasks=dm.getTask(dm.getTaskNames);
    useScheduleEditor=isequal(get_param(mgr,'UseScheduleEditor'),'on');
    switch useScheduleEditor
    case false
        tskIdx=arrayfun(@(x)contains(x.taskType,'Timer-driven'),allTasks);
        timerDrivenTasks=allTasks(tskIdx);
        for i=1:numel(timerDrivenTasks)
            [found,idx]=ismember(timerDrivenTasks(i).taskPeriod,periods);
            if found,affinities(idx)=timerDrivenTasks(i).coreNum;end
        end
    case true
        refMdl=soc.internal.connectivity.getModelConnectedToTaskManager(mgr);
        if~isequal(get_param(refMdl,'BlockType'),'ModelReference'),return;end
        refMdlName=get_param(refMdl,'ModelName');
        refMdlSchedule=get_param(refMdlName,'Schedule');
        partOrder=refMdlSchedule.Order;
        sortPeriodicPartTbl=iGetPeriodicTable(partOrder);
        for i=1:numel(sortPeriodicPartTbl)
            if ismember(sortPeriodicPartTbl(i).Partition,dm.getTaskNames)
                rateIdx=iGetRateIdx(sortPeriodicPartTbl(i));
                taskData=dm.getTask(sortPeriodicPartTbl(i).Partition);
                affinities(rateIdx)=taskData.coreNum;
            end
        end
    end
    function myIdx=iGetRateIdx(perPartTblElem)
        fndIdx=find(periods==str2double(perPartTblElem.Trigger));
        myIdx=fndIdx(1);
        periods(myIdx)=NaN;
    end
    function sortedTbl=iGetPeriodicTable(myTbl)
        partitions=myTbl.Partition;
        wrkTbl=table2struct(myTbl);
        for idxPart=length(partitions):-1:1
            wrkTbl(idxPart).Partition=partitions{idxPart};
            if~isequal(wrkTbl(idxPart).Type,'Periodic')
                wrkTbl(idxPart)=[];
            end
        end
        [~,permIdx]=sort(arrayfun(@(x)x.Index,wrkTbl));
        sortedTbl=wrkTbl(permIdx);
    end
end
