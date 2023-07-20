function setInfoProperty(info,stereotypeName,propertyName,propertyValue)




    try
        jsonData=evolutions.internal.stereotypes.getInfoPropertyData(info);

        jsonData=evolutions.internal.stereotypes.JsonUtils.setPropertyValue...
        (jsonData,stereotypeName,propertyName,propertyValue);


        evolutions.internal.stereotypes.JsonUtils...
        .serializeJSON(info,jsonData);

    catch ME
        exception=MException...
        ('evolutions:manage:SetPropertyFail',getString(message...
        ('evolutions:manage:SetPropertyFail',info.getName)));
        exception=exception.addCause(ME);
        evolutions.internal.session.EventHandler.publish('NonCriticalError',...
        evolutions.internal.ui.GenericEventData(exception));
    end

end
