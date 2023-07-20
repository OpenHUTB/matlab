function nWorkers=createPCTPool()

    stm.internal.Spinner.startSpinner(...
    getString(message('stm:general:StartingPCT',parallel.defaultProfile)));

    pool=gcp('nocreate');
    Simulink.sdi.enablePCTSupport('manual');

    if(isempty(pool))
        pool=parpool(parallel.defaultProfile);
        nWorkers=pool.NumWorkers;
    else
        nWorkers=-1*pool.NumWorkers;
    end

    stm.internal.Spinner.forceStopSpinner();

    if isa(pool,'parallel.ThreadPool')
        throwAsCaller(MException(message(...
        'parallel:lang:pool:UnsupportedFeature')));
    end
end
