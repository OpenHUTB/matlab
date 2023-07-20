function result=isSupportedEnumClass(hClass)








    if nargin>0
        hClass=convertStringsToChars(hClass);
    end

    result=coder.internal.isSupportedEnumClass(hClass);


