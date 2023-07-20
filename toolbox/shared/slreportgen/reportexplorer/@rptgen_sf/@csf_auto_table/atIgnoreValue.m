function ignoreValue=atIgnoreValue(this,objType,propName,propVal)




    ignoreValue=false;
    if strcmpi(propName,'label')
        ignoreValue=locStrcmp('?',propVal);
    elseif strcmpi(objType,'data')
        switch lower(propName)
        case{'datatype','units'}
            ignoreValue=locStrcmp('double',propVal);
        case 'range'
            ignoreValue=locStrcmp('[-inf inf]',propVal);
        case 'initvalue'
            ignoreValue=locStrcmp('0',propVal);
        end
    elseif strcmpi(objType,'machine')
        switch lower(propName)
        case 'creator'
            ignoreValue=locStrcmp('Unknown',propVal);
        case 'version'
            ignoreValue=locStrcmp('none',propVal);
        end
    end



    function tf=locStrcmp(str1,str2)



        tf=ischar(str2)&strcmp(str1,str2);








