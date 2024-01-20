function result=fixedPointConversion(dataType)
    result=[];
    sw=warning('off','fixed:numerictype:invalidMinWordLength');
    tmp=onCleanup(@()warning(sw));

    properties=eval(dataType);
    if isfixed(properties)
        signedness=properties.SignednessBool;
        wordLength=properties.WordLength;

        if isscalingunspecified(properties)
            result{1}=0;
            result{2}=signedness;
            result{3}=wordLength;
        elseif isscalingbinarypoint(properties)
            result{1}=1;
            result{2}=signedness;
            result{3}=wordLength;
            result{4}=properties.FractionLength;
        elseif isscalingslopebias(properties)
            result{1}=2;
            result{2}=signedness;
            result{3}=wordLength;
            result{4}=properties.SlopeAdjustmentFactor;
            result{5}=properties.FixedExponent;
            result{6}=properties.Bias;
        end
    else
        error(message('simulation_data_repository:sdr:ChangeSignalTypeInvalid'));
    end
end
