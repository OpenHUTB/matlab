function dropRate=isDropOverrunnigRate(modelName,thisRateTID)





    modelSampleTimes=get_param(modelName,'SampleTimes');
    discRateIdx=arrayfun(@(x)(contains(x.Description,'Discrete')),...
    modelSampleTimes);
    allDiscRates=modelSampleTimes(discRateIdx);
    assert(thisRateTID<numel(allDiscRates),'Wrong rate TID');
    thisRateIdx=arrayfun(@(x)(isequal(x.TID,thisRateTID)),allDiscRates);
    thisRatePeriod=allDiscRates(thisRateIdx).Value(1,1);



    taskMgrBlk=find_system(modelName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'MaskType','Task Manager');
    allTaskData=get_param(taskMgrBlk{1},'AllTaskData');
    dm=soc.internal.TaskManagerData(allTaskData,'evaluate',modelName);
    allTasks=dm.getTask(dm.getTaskNames);
    timerTaskIdx=arrayfun(@(x)contains(x.taskType,'Timer-driven'),allTasks);
    allTimerTasks=allTasks(timerTaskIdx);

    idx=arrayfun(@(x)(isequal(x.taskPeriod,thisRatePeriod)),allTimerTasks);
    if any(idx)
        dropRate=allTimerTasks(idx).dropOverranTasks;
    else
        dropRate=0;
    end
end
