function preCJSJob(job,canModifyJob,idForRandInit,setupGPUAllocations)




    import parallel.internal.apishared.JobInitData

    productKey=job.hGetProperty('ProductKeys');
    licenseError=[];
    try
        JobInitData.setData(job,productKey);
    catch licenseError
    end


    versionError=[];
    try
        iCheckClientVersionOnServer(job);
    catch versionError
    end

    shouldSetStartDateTime=isempty(job.StartDateTime)&&canModifyJob;
    if shouldSetStartDateTime
        job.hSetProperty({'StartDateTime',...
        'StateEnum'},...
        {datetime('now','TimeZone','local'),...
        parallel.internal.types.States.Running});
    end

    distcomp.randomInit(idForRandInit);
    if setupGPUAllocations


        parallel.internal.apishared.machineToWorkerMappingInit();
        spmdBarrier();
    else

        parallel.internal.apishared.machineToWorkerMappingReset();
    end



    if~isempty(licenseError)
        throw(distcomp.ReportableException(licenseError));
    end
    if~isempty(versionError)
        throw(distcomp.ReportableException(versionError));
    end
end



function iCheckClientVersionOnServer(job)
    try
        jobVersion=char(job.hGetProperty('Version'));
        thisVersion=parallel.internal.version.Version.Current.String;
    catch err


        versionError=MException(message('parallel:job:VersionError'));
        versionError=versionError.addCause(err);
        throw(versionError);
    end

    if~strcmp(jobVersion,thisVersion)
        versionError=MException(message('parallel:job:VersionMismatch',jobVersion,thisVersion));
        throw(versionError);
    end
end
