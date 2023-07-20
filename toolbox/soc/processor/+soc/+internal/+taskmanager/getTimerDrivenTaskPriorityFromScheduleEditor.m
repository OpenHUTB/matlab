function taskPriority=getTimerDrivenTaskPriorityFromScheduleEditor(mdl,...
    subRateIdx,baseRatePriority)





    mgrBlk=soc.internal.connectivity.getTaskManagerBlock(mdl);
    refMdlBlk=soc.internal.connectivity.getModelConnectedToTaskManager(mgrBlk);
    refMdlNam=get_param(refMdlBlk,'ModelName');
    refSchedule=get_param(refMdlNam,'Schedule');
    [rateNames,sampleTimes,~]=soc.internal.getDiscreteRatesInfoFromModel(mdl);
    taskPriority=40;
    if~isempty(refSchedule)
        allTasks=soc.internal.taskmanager.getTaskNames(mgrBlk);
        eventTasks=soc.internal.taskmanager.getEventDrivenTaskNames(mgrBlk);
        timerTasks=setdiff(allTasks,eventTasks);
        allTimerTaskIndices=refSchedule.Order.Index(timerTasks);
        numDiscRatesNotInTaskMgr=numel(rateNames)-numel(timerTasks);
        switch numDiscRatesNotInTaskMgr
        case 0
            sortedTimerTaskIndices=sort(allTimerTaskIndices,'ascend');
            fastestTimerTaskIdx=sortedTimerTaskIndices(1);
            thisTaskIdx=sortedTimerTaskIndices(subRateIdx+1);
            taskPriority=baseRatePriority+fastestTimerTaskIdx-thisTaskIdx;
        otherwise
            trigs=str2double(refSchedule.Order.Trigger);
            subRateInSchedule=ismember(sampleTimes(subRateIdx+1),trigs);
            if subRateInSchedule
                sortedTimerTaskIndices=sort(allTimerTaskIndices,'ascend');
                thisTaskIdx=sortedTimerTaskIndices(subRateIdx-...
                numDiscRatesNotInTaskMgr+1);
                taskPriority=baseRatePriority-thisTaskIdx-numDiscRatesNotInTaskMgr+1;
            else
                taskPriority=baseRatePriority-subRateIdx;
            end
        end
    end
end
