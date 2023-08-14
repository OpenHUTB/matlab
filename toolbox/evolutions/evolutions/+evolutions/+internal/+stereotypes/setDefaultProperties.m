function jsonData=setDefaultProperties(info)










    defaultStereotype=evolutions.internal.stereotypes.getDefaultStereotypeName(info);

    if ismember(defaultStereotype,info.getPrototypeNames)
        jsonData=evolutions.Stereotypes.api.Api...
        .getPrototypesDefinition(info.getPrototypeNames);
        jsonData=evolutions.internal.stereotypes.JsonUtils...
        .setPropertyValue(jsonData,defaultStereotype,...
        'Author',evolutions.internal.utils.getUserName);

        jsonData=evolutions.internal.stereotypes.JsonUtils...
        .setPropertyValue(jsonData,defaultStereotype,...
        'Created',datestr(now));

        jsonData=evolutions.internal.stereotypes.JsonUtils...
        .setPropertyValue(jsonData,defaultStereotype,...
        'Updated',datestr(now));

        jsonData=evolutions.internal.stereotypes.JsonUtils...
        .setPropertyValue(jsonData,defaultStereotype,...
        'Description','');

    else
        jsonData='{}';
    end
end
