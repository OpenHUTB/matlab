function runOptions=getRunOptions(designStudy)
    options=designStudy.RunOptions;

    if options.ShowSimulationManager
        showSimManagerOption="on";
    else
        showSimManagerOption="off";
    end

    runOptions={"ShowSimulationManager",showSimManagerOption,...
    "ShowProgress",options.ShowProgress,...
    "UseFastRestart",options.UseFastRestart,...
    "StopOnError",options.StopOnError};

    setupFcn=options.AdvancedRunOptions.SetupFcnHandle;
    if~isempty(setupFcn)
        setupFcnhandle=getFcnHandleFromString(setupFcn);
        runOptions=[runOptions,{"SetupFcn",setupFcnhandle}];
    end

    cleanupFcn=options.AdvancedRunOptions.CleanupFcnHandle;
    if~isempty(cleanupFcn)
        cleanupFcnhandle=getFcnHandleFromString(cleanupFcn);
        runOptions=[runOptions,{"SetupFcn",cleanupFcnhandle}];
    end

    if options.UseParallel
        parallelOptions=options.ParallelOptions;
        runOptions=[runOptions,{"ManageDependencies",parallelOptions.ManageDependencies,...
        "TransferBaseWorkspaceVariables",parallelOptions.TransferBaseWorkspaceVariables,...
        "RunInBackground",parallelOptions.RunInBackground}];
    end
end

function fcnHandle=getFcnHandleFromString(fcnStr)
    s=warning('error','MATLAB:str2func:invalidFunctionName');
    oc=onCleanup(@()warning(s));
    fcnHandle=str2func(fcnStr);
end