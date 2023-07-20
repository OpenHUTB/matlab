function initialGuessTbl=removeInitialGuessVariables_implementation(KS,ids)




    p=inputParser;
    p.addRequired('ids',@validateArrayText)
    p.parse(ids);

    ids=convertCharsToStrings(ids);
    KS.mSystem.removeInitialGuessVariables(ids);
    initialGuessTbl=KS.initialGuessVariables;