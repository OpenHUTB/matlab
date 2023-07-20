function clearChecks(obj)


    orig=rtw.codegenObjectives.ObjectiveCustomizer;
    orig.initialize;

    obj.currentCustomizationFile=[];
    obj.additionalCheck=[];
    obj.nameToIDHash=orig.nameToIDHash;
    obj.IDToNameHash=orig.IDToNameHash;


