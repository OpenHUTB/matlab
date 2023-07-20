function validatePositiveIntegerProperty(value,propertyName,exampleValue)







    if~isnumeric(value)
        error(message('dnnfpga:config:NumericProperty',...
        propertyName,sprintf('%g',exampleValue)));
    end

    if~isscalar(value)
        error(message('dnnfpga:config:ScalarProperty',...
        propertyName,sprintf('%g',exampleValue)));
    end

    if rem(value,1)~=0||value<=0
        valueStr=sprintf('%g',value);
        error(message('hdlcommon:plugin:IntegerProperty',...
        valueStr,propertyName,sprintf('%g',exampleValue)));
    end

end


