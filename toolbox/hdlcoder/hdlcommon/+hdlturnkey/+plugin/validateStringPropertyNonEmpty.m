function validateStringPropertyNonEmpty(value,propertyName,example)



    hdlturnkey.plugin.validateStringProperty(value,propertyName,example);
    if isempty(value)
        error(message('hdlcommon:plugin:StringPropertyNotEmpty',...
        propertyName,example));
    end
end
