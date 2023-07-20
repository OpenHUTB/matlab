function validateStringProperty(value,propertyName,exampleValue)




    if~ischar(value)&&~isstring(value)
        error(message('dnnfpga:config:StringProperty',...
        propertyName,exampleValue));
    end

end


