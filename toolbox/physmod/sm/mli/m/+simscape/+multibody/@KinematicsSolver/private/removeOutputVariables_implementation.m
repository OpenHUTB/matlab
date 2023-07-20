function outputTbl=removeOutputVariables_implementation(KS,ids)




    p=inputParser;
    p.addRequired('ids',@validateArrayText)
    p.parse(ids);

    ids=convertCharsToStrings(ids);
    KS.mSystem.removeOutputVariables(ids);
    outputTbl=KS.outputVariables;