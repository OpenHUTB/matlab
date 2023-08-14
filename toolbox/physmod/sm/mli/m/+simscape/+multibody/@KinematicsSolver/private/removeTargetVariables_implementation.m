function targetTbl=removeTargetVariables_implementation(KS,ids)




    p=inputParser;
    p.addRequired('ids',@validateArrayText)
    p.parse(ids);

    ids=convertCharsToStrings(ids);
    KS.mSystem.removeTargetVariables(ids);
    targetTbl=KS.targetVariables;