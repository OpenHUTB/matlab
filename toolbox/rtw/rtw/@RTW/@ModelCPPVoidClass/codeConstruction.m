function result=codeConstruction(hSrc)



    MSLDiagnostic('RTW:fcnClass:voidclassdeprecation').reportAsWarning;

    result.FunctionName=hSrc.FunctionName;

    result.ModelClassName=hSrc.ModelClassName;

    result.ClassNamespace=hSrc.ClassNamespace;

    if isempty(hSrc.cache)
        result.ArgSpecData=hSrc.Data;
    else
        result.ArgSpecData=hSrc.cache.Data;
    end

