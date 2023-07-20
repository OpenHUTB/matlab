function validateStringProperty(value,propertyName,example)



    if~ischar(value)
        if iscell(value)
            error(message('hdlcommon:plugin:StringPropertyNotCell',...
            propertyName,example));
        else
            error(message('hdlcommon:plugin:StringProperty',...
            value,propertyName,example));
        end
    end
end