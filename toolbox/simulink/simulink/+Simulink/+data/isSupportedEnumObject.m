function result=isSupportedEnumObject(hObj)






    if nargin>0
        hObj=convertStringsToChars(hObj);
    end

    result=coder.internal.isSupportedEnumObject(hObj);


