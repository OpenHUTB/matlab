function dictionaryObj=constructDictionaryObject(dictionaryObj,p,sourceName)




    sourceName=convertStringsToChars(sourceName);

    hlp=coder.internal.CoderDataStaticAPI.getHelper;
    valid=coder.dictionary.internal.isValidSource(sourceName);
    if valid
        sourceName=coder.dictionary.internal.resolveValidSourceName(sourceName);
        dictionaryObj.Name=sourceName;
        if p.Results.addSourceDictionary
            if slfeature('CodeGenerationProject')&&p.Results.searchProjectClosure
                needLocal=false;
            else
                needLocal=true;
            end
            sr=slroot;
            if sr.isValidSlObject(sourceName)
                if strcmp(coder.dictionary.internal.getPlatformType(sourceName),'FunctionPlatform')
                    sourceName=get_param(sourceName,'EmbeddedCoderDictionary');
                    dictionaryObj.Name=sourceName;
                end
            end
            cdef=hlp.openDD(sourceName,'C',needLocal);
            dictionaryObj.sourceDictionary=cdef.owner;
        end
    else
        DAStudio.error('SimulinkCoderApp:data:InvalidSourceName',sourceName);
    end


    licenseList={'Matlab_Coder','Real-Time_Workshop','RTW_Embedded_Coder'};
    success=true;
    for i=1:length(licenseList)
        [checkedOut,errmsg]=license('checkout',licenseList{i});
        success=success&&checkedOut;
    end
    if~success
        DAStudio.error('SimulinkCoderApp:data:LicenseCheckoutFail',errmsg);
    end
    dictionaryObj.sourceDictionary.isRemoved=false;
end
