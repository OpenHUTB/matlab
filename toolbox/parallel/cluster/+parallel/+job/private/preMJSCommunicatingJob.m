function preMJSCommunicatingJob(job,task)




    import parallel.internal.apishared.JobInitData




    try


        productKey=job.hGetProperty('ProductKeys');
        licenseError=[];
        try

            JobInitData.setData(job,productKey);
        catch licenseError
        end
    catch err
        throw(distcomp.handleJavaException(job,err));
    end

    try

        if ispc
            s=warning('off','parallel:lang:mpi:MpiThreadSupportNotSupported');
            cleanup=onCleanup(@()warning(s));
        end
        job.hMpiInit(task);
        if ispc
            delete(cleanup)
        end




        distcomp.randomInit(spmdIndex);



        parallel.internal.apishared.machineToWorkerMappingInit();
    catch err
        throw(distcomp.handleJavaException(job,err));
    end



    if~isempty(licenseError)
        throw(distcomp.ReportableException(licenseError));
    end


end

