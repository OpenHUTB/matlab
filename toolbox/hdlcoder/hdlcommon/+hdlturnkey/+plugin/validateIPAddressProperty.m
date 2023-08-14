

function validateIPAddressProperty(value,propertyName,example)

    if isempty(value)
        error(message('hdlcommon:plugin:StringPropertyNotEmpty',...
        propertyName,example));
    end
    flag=hdlturnkey.plugin.validateIPAddressFormat(value,propertyName);
    if(flag==false)
        error(message('hdlcommon:plugin:InvalidIPAddress',value));
    end
end