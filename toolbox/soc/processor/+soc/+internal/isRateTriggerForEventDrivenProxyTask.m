function ret=isRateTriggerForEventDrivenProxyTask(modelName,rateIdx)






    import soc.internal.*

    ret=false;
    [~,rateSampleTimes,~]=getDiscreteRatesInfoFromModel(modelName);
    thisRateSampleTime=rateSampleTimes(rateIdx+1);
    theMap=connectivity.getTaskManagerEventSources(modelName);
    if isempty(theMap)
        return
    end
    keys=theMap.keys;
    for i=1:numel(keys)
        thisEventSrc=theMap(keys{i});
        if thisEventSrc.IsFromDialog&&...
            isequal(thisEventSrc.SampleTime,thisRateSampleTime)
            ret=true;
            break;
        end
    end
end
