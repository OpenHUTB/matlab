function updateNumDesignPoints( singleParameterSpace )

arguments
    singleParameterSpace( 1, 1 )simulink.multisim.mm.design.SingleParameterSpace
end

try
    paramSpaceSampler = simulink.multisim.internal.sampler.SingleParameterSpace( singleParameterSpace );
    numDesignPoints = paramSpaceSampler.getNumDesignPoints(  );
    singleParameterSpace.Values.ErrorText = "";
    singleParameterSpace.NumDesignPoints = numDesignPoints;
catch
    singleParameterSpace.Values.ErrorText = "Invalid expression";
    validDesignPoints = 0;
    singleParameterSpace.NumDesignPoints = validDesignPoints;
end
end
