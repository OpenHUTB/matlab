function initialGuessTbl=addInitialGuessVariables_implementation(KS,ids)




    p=inputParser;
    p.addRequired('ids',@validateArrayText)
    p.parse(ids);

    ids=convertCharsToStrings(ids);
    KS.mSystem.addInitialGuessVariables(ids);
    initialGuessTbl=KS.initialGuessVariables;
