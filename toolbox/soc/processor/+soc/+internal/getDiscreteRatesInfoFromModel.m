function[names,sampleTimes,sampleTimesAndOffsets]=getDiscreteRatesInfoFromModel(modelName)








    infoST=get_param(modelName,'SampleTimes');
    assert(~isempty(infoST),...
    'The model must be in updated state before calling this function')
    idxNonEmptyTIDs=arrayfun(@(x)(~isempty(x.TID)),infoST);
    infoNonEmptyST=infoST(idxNonEmptyTIDs);
    idxNumericPeriod=arrayfun(@(x)(isnumeric(x.Value)),infoNonEmptyST);
    infoNumericST=infoNonEmptyST(idxNumericPeriod);
    stPeriods=arrayfun(@(x)(x.Value(1)),infoNumericST,'UniformOutput',false);
    idxDiscreteRates=cellfun(@(x)(~isinf(x(1))&&x(1)>0),stPeriods);
    discreteRates=infoNumericST(idxDiscreteRates);
    names=arrayfun(@(x)(x.Description),discreteRates,'UniformOutput',false);
    names=strrep(names,' ','_');
    sampleTimesAndOffsets=arrayfun(@(x)(x.Value),discreteRates,'UniformOutput',false);
    sampleTimes=cell2mat(stPeriods(idxDiscreteRates));
end
