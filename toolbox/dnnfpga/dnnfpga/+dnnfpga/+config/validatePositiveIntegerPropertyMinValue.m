function validatePositiveIntegerPropertyMinValue(value,propertyName,minValue,exampleValue)







    if isscalar(value)
        valueScalar=value;
        minValueScalar=minValue;
        dnnfpga.config.validatePositiveIntegerProperty(value,propertyName,exampleValue);
    else
        valueScalar=prod(value);
        minValueScalar=prod(minValue);
        dnnfpga.config.validatePositiveIntegerVectorProperty(value,propertyName,exampleValue);
    end


    if(valueScalar<minValueScalar)
        valueDisp=dnnfpga.config.refineValueForDisplay(value);
        minValueDiap=dnnfpga.config.refineValueForDisplay(minValue);
        exampleValueDiap=dnnfpga.config.refineValueForDisplay(exampleValue);
        error(message('dnnfpga:config:IntegerPropertyMinValue',...
        valueDisp,propertyName,minValueDiap,exampleValueDiap));

    end


end


