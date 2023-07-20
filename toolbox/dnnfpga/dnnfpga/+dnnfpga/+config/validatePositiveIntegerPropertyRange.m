function validatePositiveIntegerPropertyRange(value,propertyName,valueRangeVector,exampleValue)






    dnnfpga.config.validatePositiveIntegerProperty(value,propertyName,exampleValue);


    minValue=valueRangeVector(1);
    maxValue=valueRangeVector(2);

    if(value<minValue)||(value>maxValue)
        error(message('dnnfpga:config:IntegerPropertyValueRange',...
        value,propertyName,minValue,maxValue,exampleValue));

    end


end


