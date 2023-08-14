function semIdx=getProxyTaskSemaphoreIdx(modelName,taskName)




    import soc.internal.*

    theMap=connectivity.getTaskManagerEventSources(modelName);
    taskInfo=theMap(taskName);
    taskSampleTime=taskInfo.SampleTime;
    [~,sampleTimes,~]=getDiscreteRatesInfoFromModel(modelName);

    srcIdx=0;
    for idx=1:numel(sampleTimes)
        thisSampleTime=sampleTimes(idx);
        rateIdx=idx-1;
        isSrc=isRateTriggerForEventDrivenProxyTask(modelName,rateIdx);
        if isSrc
            if isequal(taskSampleTime,thisSampleTime)
                semIdx=int16(srcIdx);
                return;
            end
            srcIdx=srcIdx+1;
        end
    end



    theMap=connectivity.getTaskManagerEventSources(modelName);
    keys=theMap.keys;

    aperiodicTasks={};
    for idx=1:numel(keys)
        thisEventSrc=theMap(keys{idx});
        if thisEventSrc.IsFromDialog,continue;end
        aperiodicTasks{end+1}=keys{idx};%#ok<AGROW>
    end
    assert(~isempty(aperiodicTasks),'No aperiodic proxy tasks');
    [~,locIdx]=ismember(taskName,aperiodicTasks);
    locIdx=locIdx-1;
    semIdx=int16(srcIdx+locIdx);
end
