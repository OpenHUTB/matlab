function validatePositiveNumericProperty(value,propertyName,exampleValue)





    if~isnumeric(value)
        error(message('dnnfpga:config:NumericProperty',...
        propertyName,sprintf('%g',exampleValue)));
    end

    if~isscalar(value)
        error(message('dnnfpga:config:ScalarProperty',...
        propertyName,sprintf('%g',exampleValue)));
    end

    if value<=0
        valueStr=sprintf('%g',value);
        error(message('dnnfpga:config:PositiveProperty',...
        valueStr,propertyName,sprintf('%g',exampleValue)));
    end

end


