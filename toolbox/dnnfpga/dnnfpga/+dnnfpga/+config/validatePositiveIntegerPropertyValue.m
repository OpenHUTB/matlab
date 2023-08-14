function validatePositiveIntegerPropertyValue(value,propertyName,choices,defaultChoice)






    if nargin<4
        defaultChoice=choices{1};
    end


    dnnfpga.config.validatePositiveIntegerProperty(value,propertyName,defaultChoice);


    dnnfpga.config.validateIntegerPropertyValue(value,propertyName,choices);

end
