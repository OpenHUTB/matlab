function validateRequiredMethod(checkValue,methodName,example)

    if isempty(checkValue)
        error(message('hdlcommon:plugin:MethodRequired',...
        methodName,example));
    end
end