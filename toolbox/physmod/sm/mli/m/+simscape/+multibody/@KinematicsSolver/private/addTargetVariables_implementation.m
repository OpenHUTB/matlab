function targetTbl=addTargetVariables_implementation(KS,ids)




    p=inputParser;
    p.addRequired('ids',@validateArrayText)
    p.parse(ids);

    ids=convertCharsToStrings(ids);
    KS.mSystem.addTargetVariables(ids);
    targetTbl=KS.targetVariables;
