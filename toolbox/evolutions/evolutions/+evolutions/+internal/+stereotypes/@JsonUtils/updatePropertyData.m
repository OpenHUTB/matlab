function updatePropertyData(info)









    jsonData=evolutions.Stereotypes.api.Api...
    .getPrototypesDefinition(info.getPrototypeNames);

    if isfile(info.PropertyDataFile)


        dataOnDisk=evolutions.internal.stereotypes.getInfoPropertyData(info);
        jsonData=setDataFromOnDiskValues(jsonData,dataOnDisk);
    end

    evolutions.internal.stereotypes.JsonUtils.serializeJSON(info,jsonData);
end

function newData=setDataFromOnDiskValues(newData,oldData)



    newDataStereotypes=jsondecode(newData);

    for stereotypeIdx=1:numel(newDataStereotypes)
        stereotype=newDataStereotypes(stereotypeIdx);

        for propertyIdx=1:numel(stereotype.Properties)
            property=stereotype.Properties(propertyIdx);


            try
                oldValue=evolutions.internal.stereotypes.JsonUtils.getPropertyValue...
                (oldData,stereotype.Name,property.Name);
            catch

                continue;
            end

            newData=evolutions.internal.stereotypes.JsonUtils.setPropertyValue...
            (newData,stereotype.Name,property.Name,oldValue);

        end
    end

end
