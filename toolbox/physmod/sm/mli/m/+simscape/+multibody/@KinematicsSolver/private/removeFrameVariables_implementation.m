function frameTbl=removeFrameVariables_implementation(KS,ids)




    p=inputParser;
    p.addRequired('ids',@validateArrayText)
    p.parse(ids);

    ids=convertCharsToStrings(ids);
    KS.mSystem.removeFrameVariables(ids);
    frameTbl=KS.frameVariables;