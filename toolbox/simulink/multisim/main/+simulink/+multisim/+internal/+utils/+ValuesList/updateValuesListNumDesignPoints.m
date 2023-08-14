function updateValuesListNumDesignPoints(valuesListElement)





    singleParameterSpace=simulink.multisim.internal.getParentContainer(valuesListElement,"SingleParameterSpace");

    try
        paramSpaceSampler=simulink.multisim.internal.sampler.SingleParameterSpace(singleParameterSpace);
        numDesignPoints=paramSpaceSampler.getNumDesignPoints();
        singleParameterSpace.NumDesignPoints=numDesignPoints;
    catch
        singleParameterSpace.NumDesignPoints=0;
    end
end