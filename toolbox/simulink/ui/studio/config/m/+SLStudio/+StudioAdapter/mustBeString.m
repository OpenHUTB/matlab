function mustBeString(value,exceptionStr)
    isCharOrString=ischar(value)||isstring(value);
    if~isCharOrString||strlength(value)<=0
        errorID='MATLAB:class:RequireScalarText';
        messageObject=message(errorID,exceptionStr);
        error(errorID,messageObject.getString);
    end
end