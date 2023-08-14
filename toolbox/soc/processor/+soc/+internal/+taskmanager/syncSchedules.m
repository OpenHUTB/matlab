function syncSchedules(hMdl,isStartSim)




    if isequal(nargin,1),isStartSim=true;end
    mgrBlk=soc.internal.connectivity.getTaskManagerBlock(hMdl,true);
    if isempty(mgrBlk)||(iscell(mgrBlk)&&numel(mgrBlk)>1),return;end
    useSchedEditor=isequal(get_param(mgrBlk,'UseScheduleEditor'),'on');
    if useSchedEditor
        mdlBlk=soc.internal.connectivity.getModelConnectedToTaskManager(mgrBlk);
        refMdl=get_param(mdlBlk,'ModelName');
        if~bdIsLoaded(refMdl),load_system(refMdl);end
        refSchedule=get_param(refMdl,'Schedule');
        topSchedule=get_param(hMdl,'Schedule');
        if isempty(topSchedule.Order)
            set_param(hMdl,'SimulationCommand','Update');
            topSchedule=get_param(hMdl,'Schedule');
        end
        topSchedule=applyRefModelScheduleOrderToTopModel(topSchedule,refSchedule);
        set_param(hMdl,'Schedule',topSchedule);
        if isStartSim
            set_param(hMdl,'SimulationCommand','Start');
        end
    end
end


function topSchedule=applyRefModelScheduleOrderToTopModel(topSchedule,refSchedule)
    topSchedule=iApplyWorkaround(topSchedule);
    refMdlPeriodicPartStructSorted=locGetPeriodicPartionsAndRelativeOrder(refSchedule);
    topMdlPeriodicPartStruct=locGetPeriodicPartionsStruct(topSchedule);
    refList=arrayfun(@(x)x.Name,refMdlPeriodicPartStructSorted,'UniformOutput',false);
    topMdlPeriodicPartStruct=locFilterOutPartitionsNotInRefList(topMdlPeriodicPartStruct,refList);
    topMdlPeriodicPartIndices=arrayfun(@(x)x.Index,topMdlPeriodicPartStruct);
    for i=1:numel(topMdlPeriodicPartStruct)
        thisPartition=topMdlPeriodicPartStruct(i).Name;
        pos=arrayfun(@(x)isequal(x.Name,thisPartition),refMdlPeriodicPartStructSorted);
        if~any(pos),continue;end
        thisPartitionRelIndex=refMdlPeriodicPartStructSorted(pos).Index;
        thisPartitionNewIndex=topMdlPeriodicPartIndices(thisPartitionRelIndex);
        topSchedule.Order.Index(thisPartition)=thisPartitionNewIndex;
    end
    topSchedule=iApplyWorkaround(topSchedule);
    function schedule=iApplyWorkaround(schedule)


        schedule.PartitionProperties.Priority=100-...
        schedule.PartitionProperties.Priority;
    end
end

















function partStruct=locGetPeriodicPartionsStruct(schedule)
    partStruct=[];
    parts=schedule.Order.Partition;
    for i=1:numel(parts)
        idx=numel(partStruct)+1;
        pType=schedule.Order.Type(parts{i});
        if~isequal(pType,simulink.schedule.PartitionType('Periodic')),continue;end
        partStruct(idx).Name=parts{i};%#ok<AGROW> 
        partStruct(idx).Index=schedule.Order.Index(parts{i});%#ok<AGROW> 
    end
end


function partStruct=locFilterOutPartitionsNotInRefList(partStruct,refList)
    for i=numel(partStruct):-1:1
        if~ismember(partStruct(i).Name,refList)
            partStruct(i)=[];
        end
    end
end


function sortedPartStruct=locGetPeriodicPartionsAndRelativeOrder(schedule)
    partStruct=locGetPeriodicPartionsStruct(schedule);
    [~,I]=sort(arrayfun(@(x)x.('Index'),partStruct));
    sortedPartStruct=partStruct(I);
    for i=1:numel(sortedPartStruct),sortedPartStruct(i).Index=i;end
end
