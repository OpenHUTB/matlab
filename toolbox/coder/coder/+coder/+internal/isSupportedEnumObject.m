function result=isSupportedEnumObject(aObj)






    if(isobject(aObj)&&~isempty(aObj))
        result=coder.internal.isSupportedEnumClass(metaclass(aObj));
    else
        result=false;
    end


