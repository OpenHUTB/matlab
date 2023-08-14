function propertyValue=getPropertyValue(object,propertyName)





    hProp=findprop(object,propertyName);
    if isa(hProp,'meta.DynamicProperty')
        propertyValue=object.getDynamicProp(propertyName);
    else
        propertyValue=object.(propertyName);
    end

end

