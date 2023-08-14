function[taskNames,sampleTimesOffsets,isTaskMgrRate]=getTimerDrivenTasks(mdl)





    isTaskMgrRate=[];

    [taskNames,mdlSampleTimes,sampleTimesOffsets]=...
    soc.internal.getDiscreteRatesInfoFromModel(mdl);
    if codertarget.utils.isTaskManagerFound(mdl)
        mgrBlk=soc.internal.connectivity.getTaskManagerBlock(mdl,true);
        if~isempty(taskNames)
            isTaskMgrRate=false(numel(taskNames),1);
            rawTaskData=get_param(mgrBlk,'AllTaskData');
            evlTaskData=soc.internal.TaskManagerData(rawTaskData,'evaluate',mdl);
            allTasks=evlTaskData.getTask(evlTaskData.getTaskNames);
            taskIdx=arrayfun(@(x)contains(x.taskType,'Timer-driven'),allTasks);
            timerTasks=allTasks(taskIdx);



            useSchedEditor=isequal(get_param(mgrBlk,'UseScheduleEditor'),'on');
            if useSchedEditor
                for i=1:numel(timerTasks)
                    taskPeriod=timerTasks(i).taskPeriod;
                    rateIdx=find(mdlSampleTimes==taskPeriod);
                    if isscalar(rateIdx)
                        taskNames{rateIdx}=timerTasks(i).taskName;
                        isTaskMgrRate(rateIdx)=true;
                    elseif isvector(rateIdx)
                        mySchedule=get_param(mdl,'Schedule');
                        loc=find(str2double(mySchedule.Order.Trigger)==taskPeriod);
                        qualifiedParts=mySchedule.Order(loc,:);
                        myIdx=qualifiedParts.Index(timerTasks(i).taskName);
                        myPosWithinQualifiedParts=qualifiedParts.Index==myIdx;
                        finalIdx=rateIdx(myPosWithinQualifiedParts);
                        taskNames{finalIdx}=timerTasks(i).taskName;
                        isTaskMgrRate(finalIdx)=true;
                    end
                end
            else
                for i=1:numel(timerTasks)
                    [found,rateIdx]=ismember(timerTasks(i).taskPeriod,mdlSampleTimes);
                    if found
                        taskNames{rateIdx}=timerTasks(i).taskName;
                        isTaskMgrRate(rateIdx)=true;
                    end
                end
            end
            taskNames=locCreateTaskMappingFile(mdl,taskNames,allTasks,...
            timerTasks,isTaskMgrRate);
        end
    else
        isTaskMgrRate=true(numel(taskNames),1);
    end
end


function names=locCreateTaskMappingFile(mdl,names,tasks,timerTasks,isTaskMgrRate)




    buildDir=RTW.getBuildDir(mdl);
    filePath=fullfile(buildDir.BuildDirectory,[mdl,'_mapping.txt']);
    try
        if isequal(numel(tasks),numel(timerTasks)),mode='w';else,mode='a';end
        fid=fopen(filePath,mode);
        for i=1:numel(names)
            if isTaskMgrRate(i)
                aliasNames{i}=['_socbTT',num2str(i)];%#ok<*AGROW>
            else
                aliasNames{i}=names{i};
            end
            fprintf(fid,'ActualName = %s, AliasName = %s\n',names{i},aliasNames{i});
        end
        fclose(fid);
        names=aliasNames;
    catch me %#ok<NASGU>
        fclose(fid);
    end
end
