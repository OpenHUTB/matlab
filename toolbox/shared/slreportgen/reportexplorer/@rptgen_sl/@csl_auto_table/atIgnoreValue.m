function ignoreValue=atIgnoreValue(this,objType,propName,propVal)





    ignoreValue=false;
    if ischar(propVal)
        if strcmpi(propVal,'auto')
            ignoreValue=true;
        end
    end
