function validateIntegerProperty(value,propertyName,example)


    if~isnumeric(value)||value<=0
        error(message('hdlcommon:plugin:IntegerProperty',...
        value,propertyName,example));
    end
end