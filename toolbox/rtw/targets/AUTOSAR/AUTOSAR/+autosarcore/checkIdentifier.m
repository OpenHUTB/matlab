function[isValid,errmsg,errId]=checkIdentifier(str,idType,maxShortNameLength)





    [isValid,errId]=autosarcore.checkIdentifierErrID(str,idType,maxShortNameLength);


    invalidLengthErrIds={...
    'RTW:autosar:invalidShortNameLength',...
    'RTW:autosar:invalidAbsPathShortNameLength',...
    'RTW:autosar:invalidAbsPathLength'};

    if isValid==true
        errmsg=[];
    else

        if ismember(errId,invalidLengthErrIds)
            errmsg=DAStudio.message(errId,str,maxShortNameLength);
        else
            errmsg=DAStudio.message(errId,str);
        end
    end


