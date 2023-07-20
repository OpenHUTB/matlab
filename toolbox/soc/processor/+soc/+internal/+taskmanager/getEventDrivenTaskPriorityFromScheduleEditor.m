function taskPriority=getEventDrivenTaskPriorityFromScheduleEditor(mdl,...
    taskName,taskPriority)




    mgrBlk=soc.internal.connectivity.getTaskManagerBlock(mdl);
    refMdlBlk=soc.internal.connectivity.getModelConnectedToTaskManager(mgrBlk);
    refMdlNam=get_param(refMdlBlk,'ModelName');
    refSchedule=get_param(refMdlNam,'Schedule');
    [rateNames,~,~]=soc.internal.getDiscreteRatesInfoFromModel(mdl);
    if~isempty(refSchedule)
        baseRatePriority=40;
        allTasks=soc.internal.taskmanager.getTaskNames(mgrBlk);
        eventTasks=soc.internal.taskmanager.getEventDrivenTaskNames(mgrBlk);
        if~ismember(taskName,eventTasks),return;end
        timerTasks=setdiff(allTasks,eventTasks);
        numDiscRatesNotInTaskMgr=numel(rateNames)-numel(timerTasks);
        switch numDiscRatesNotInTaskMgr
        case 0
            timerTaskIndices=refSchedule.Order.Index(timerTasks);
            sortedTimerTaskIndices=sort(timerTaskIndices,'ascend');
            baseRateIdx=sortedTimerTaskIndices(1);
            thisTaskIdx=refSchedule.Order.Index(taskName);
            taskPriority=baseRatePriority+baseRateIdx-thisTaskIdx;
        otherwise
            thisTaskIdx=refSchedule.Order.Index(taskName);
            taskPriority=baseRatePriority-thisTaskIdx-...
            numDiscRatesNotInTaskMgr+1;
        end
    end
end
