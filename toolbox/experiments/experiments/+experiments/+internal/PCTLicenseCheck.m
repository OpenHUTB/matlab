function PCTLicenseCheck()

    import experiments.internal.ExperimentException
    [~,result]=matlab.internal.parallel.canUseParallelPool;
    if~result.IsInstalled
        throw(ExperimentException(message('experiments:manager:NoParallelInstalled',...
        message('experiments:manager:ExpExectionMode_Simultaneous').getString())));
    end
    if~result.IsLicensed
        throw(ExperimentException(message('experiments:manager:NoParallelLicense',...
        message('experiments:manager:ExpExectionMode_Simultaneous').getString())));
    end
    if~result.PoolRunning
        throw(ExperimentException(message('experiments:manager:ParallelPoolCannotBeStarted',result.ErrorMessage)));
    end
    if isa(gcp,'parallel.ThreadPool')
        throw(ExperimentException(message('parallel:lang:pool:UnsupportedFeature')));
    end
end
