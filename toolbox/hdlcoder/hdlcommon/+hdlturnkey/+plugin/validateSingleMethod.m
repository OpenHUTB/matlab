function validateSingleMethod(checkValue,methodName)

    if~isempty(checkValue)
        error(message('hdlcommon:plugin:MethodOnlyOnce',...
        methodName));
    end
end