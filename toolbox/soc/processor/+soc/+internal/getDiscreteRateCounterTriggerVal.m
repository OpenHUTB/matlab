function val=getDiscreteRateCounterTriggerVal(modelName,idx)




    import soc.internal.*

    [~,rateSampleTimes,~]=getDiscreteRatesInfoFromModel(modelName);
    baseRate=min(rateSampleTimes);
    rateRatios=rateSampleTimes/baseRate;
    assert(ismember(idx,1:numel(rateSampleTimes)),...
    'Illegal value for the rate index.');
    val=int16(rateRatios(idx));

end
