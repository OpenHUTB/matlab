function validateRequiredProperty(value,propertyName,example)
    if isempty(value)
        error(message('hdlcommon:plugin:RequiredProperty',...
        propertyName,example));
    end
end