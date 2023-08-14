function validateStringProp(value,propertyName,example)

    if~ischar(value)||isempty(value)
        if iscell(value)
            error(message('hdlcommon:plugin:StringPropertyNotCell',...
            propertyName,example));
        elseif isempty(value)
            error(message('hdlcommon:plugin:StringPropertyNotEmpty',...
            propertyName,example));
        else
            error(message('hdlcommon:plugin:StringProperty',...
            value,propertyName,example));
        end
    end
end