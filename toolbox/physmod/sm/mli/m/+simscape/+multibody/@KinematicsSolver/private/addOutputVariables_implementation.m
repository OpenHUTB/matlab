function outputTbl=addOutputVariables_implementation(KS,ids)




    p=inputParser;
    p.addRequired('ids',@validateArrayText)
    p.parse(ids);

    ids=convertCharsToStrings(ids);
    KS.mSystem.addOutputVariables(ids);
    outputTbl=KS.outputVariables;
