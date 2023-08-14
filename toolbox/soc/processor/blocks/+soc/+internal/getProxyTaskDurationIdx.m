function idx=getProxyTaskDurationIdx(modelName,taskName)




    import soc.internal.*

    [~,sampleTimes,~]=getDiscreteRatesInfoFromModel(modelName);
    numDiscreteRates=numel(sampleTimes);
    eventDrivenProxyTasks=getEventDrivenProxyTaskNames(modelName);
    [found,idx]=ismember(taskName,eventDrivenProxyTasks);
    assert(found,[taskName,' is not an event-driven proxy task']);
    idx=numDiscreteRates+idx-1;
    idx=int16(idx);
end