function validateNonNegDoubleProperty(value,propertyName,example)




    if~isnumeric(value)||value<0
        error(message('hdlcommon:plugin:NonNegValueProperty',...
        num2str(value),propertyName,example));
    end
end