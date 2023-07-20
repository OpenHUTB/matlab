function[useBruteForce,nStoreInteger]=canBruteForceGridingBeUsed(rangeObject,dataTypes)








    nDimensions=rangeObject.NumberOfDimensions;
    nStoreInteger=inf(1,nDimensions);
    for ii=1:nDimensions
        nStoreInteger(ii)=double(fixed.internal.utility.cardinality.getCardinality(rangeObject.Interval(ii),dataTypes(ii)));
    end

    useBruteForce=prod(nStoreInteger)<2^19;
end
