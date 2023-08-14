function shuttingDown=isThisAProjectShutdownCall()



    import matlab.internal.project.util.doesStackContainFunction;
    shuttingDown=doesStackContainFunction('runMATLABScriptDuringShutdown');

end