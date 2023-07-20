function value=getInfoProperty(info,stereotypeName,propertyName)




    jsonData=evolutions.internal.stereotypes.getInfoPropertyData(info);

    value=evolutions.internal.stereotypes.JsonUtils.getPropertyValue...
    (jsonData,stereotypeName,propertyName);
end
