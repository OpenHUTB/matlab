function val=getPropertyValue(jsonData,stereotypeName,propertyName)





    structData=jsondecode(jsonData);


    stereotypeNameArray={structData.Name};
    stereotypeIdx=strcmp(stereotypeNameArray,stereotypeName);
    stereotype=structData(stereotypeIdx);


    properties=stereotype.Properties;


    propertyNameArray={properties.Name};
    propertyIdx=strcmp(propertyNameArray,propertyName);
    property=properties(propertyIdx);

    val=property.Value;

end
