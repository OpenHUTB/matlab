function outData=setPropertyValue(jsonData,stereotypeName,propertyName,propertyValue)





    stereotypes=jsondecode(jsonData);


    stereotypeNameArray={stereotypes.Name};
    stereotypeIdx=find(strcmp(stereotypeNameArray,stereotypeName));

    if isempty(stereotypeIdx)
        outData=jsonencode(stereotypes);
        return;
    end

    properties=stereotypes(stereotypeIdx).Properties;


    propertyNameArray={properties.Name};
    propertyIdx=find(strcmp(propertyNameArray,propertyName));
    if isempty(propertyIdx)
        outData=jsonencode(stereotypes);
        return;
    end

    type=stereotypes(stereotypeIdx).Properties(propertyIdx).Type;
    formattedValue=evolutions.internal.stereotypes.JsonUtils.getTypeCastValue(propertyValue,type);
    stereotypes(stereotypeIdx).Properties(propertyIdx).Value=formattedValue;

    outData=jsonencode(stereotypes);

end
