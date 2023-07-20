function validatePositiveIntegerVectorProperty(value,propertyName,exampleValue)







    if~isnumeric(value)
        error(message('dnnfpga:config:NumericProperty',...
        propertyName,sprintf('[%s]',num2str(exampleValue))));
    end

    if~isvector(value)||isscalar(value)||iscell(value)
        error(message('dnnfpga:config:VectorProperty',...
        propertyName,sprintf('[%s]',num2str(exampleValue))));
    end

    negativeValue=false;
    for ii=1:length(value)
        aValue=value(ii);
        if rem(aValue,1)~=0||aValue<=0
            negativeValue=true;
            break;
        end
    end
    if negativeValue
        error(message('dnnfpga:config:VectorIntegerProperty',...
        sprintf('[%s]',num2str(value)),propertyName,...
        sprintf('[%s]',num2str(exampleValue))));
    end


end


