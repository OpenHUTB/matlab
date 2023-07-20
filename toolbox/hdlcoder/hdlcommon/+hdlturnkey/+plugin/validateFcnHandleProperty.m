function validateFcnHandleProperty(value,propertyName,example)



    if~isempty(value)&&~isa(value,'function_handle')
        error(message('hdlcommon:plugin:FcnHandleProperty',...
        value,propertyName,example));
    end
end