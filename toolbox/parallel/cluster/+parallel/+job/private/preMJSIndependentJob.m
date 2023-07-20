function preMJSIndependentJob(job,task)




    import parallel.internal.apishared.JobInitData

    try


        productKey=job.hGetProperty('ProductKeys');
        licenseError=[];
        try

            JobInitData.setData(job,productKey);
        catch licenseError
        end

        distcomp.randomInit(task.Id);


        parallel.internal.apishared.machineToWorkerMappingReset();
    catch err
        throw(distcomp.handleJavaException(job,err));
    end



    if~isempty(licenseError)
        throw(distcomp.ReportableException(licenseError));
    end


end
