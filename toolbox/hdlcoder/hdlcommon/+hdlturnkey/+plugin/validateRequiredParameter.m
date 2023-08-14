function validateRequiredParameter(paramValue,paramName,example)
    if isempty(paramValue)
        error(message('hdlcommon:plugin:InvalidParameter',paramName,example));
    end
end