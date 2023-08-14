function validatePositiveIntegerPropertyMultiple(value,propertyName,multipleOf,exampleValue)







    if isscalar(value)
        valueScalar=value;
        multipleOfScalar=multipleOf;
        dnnfpga.config.validatePositiveIntegerProperty(value,propertyName,exampleValue);
    else
        valueScalar=prod(value);
        multipleOfScalar=prod(multipleOf);
        dnnfpga.config.validatePositiveIntegerVectorProperty(value,propertyName,exampleValue);
    end


    if rem(valueScalar,multipleOfScalar)~=0
        valueDisp=dnnfpga.config.refineValueForDisplay(value);
        multipleOfDisp=dnnfpga.config.refineValueForDisplay(multipleOf);
        exampleValueDisp=dnnfpga.config.refineValueForDisplay(exampleValue);
        error(message('dnnfpga:config:IntegerPropertyMultiple',...
        valueDisp,propertyName,multipleOfDisp,exampleValueDisp));

    end


end


