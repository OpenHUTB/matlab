function validateBooleanProperty(value,propertyName,example)



    if~islogical(value)
        error(message('hdlcommon:plugin:BooleanProperty',...
        value,propertyName,example));
    end
end