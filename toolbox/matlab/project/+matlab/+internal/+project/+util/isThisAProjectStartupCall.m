function startingUp=isThisAProjectStartupCall()



    import matlab.internal.project.util.doesStackContainFunction;
    startingUp=doesStackContainFunction('runMATLABScriptDuringStartup');

end