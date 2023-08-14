function varVal=getVarValuefromQualifiedName(mdl,qualifiedName,ddSection)





    [varName,ddName]=...
    Simulink.dd.private.getVarAndDictionaryNameFromQualifiedVarName(qualifiedName);

    ddName=ddName{:};

    if isempty(ddName)
        varVal=slprivate('evalinScopeSection',mdl,varName,...
        ddSection,true);
    else
        dd=Simulink.dd.open(ddName);
        varVal=evalin(dd,varName,ddSection);
    end

