function signature=getPreview(hSrc,~)



    MSLDiagnostic('RTW:fcnClass:voidclassdeprecation').reportAsWarning;
    if~isempty(hSrc.cache)
        targetObj=hSrc.cache;
    else
        targetObj=hSrc;
    end

    signature=[targetObj.ModelClassName,' :: ',targetObj.FunctionName,'( )'];