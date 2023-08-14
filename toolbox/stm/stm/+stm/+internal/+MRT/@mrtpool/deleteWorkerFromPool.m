function deleteWorkerFromPool(poolRoot,workerId,exitMATLAB)




    warnstat=warning('query','all');
    warning('off','MATLAB:DELETE:FileNotFound');
    warning('off','MATLAB:DELETE:Permission');
    wCleanup=onCleanup(@()warning(warnstat));
    workerInfo=stm.internal.MRT.mrtpool.getWorkerInfo(poolRoot,workerId);
    try
        if(exist(workerInfo.startedFile,'file'))
            try
                delete(workerInfo.startedFile);
            catch
            end
        end
        if(exist(workerInfo.workerPIdFile,'file'))
            try
                delete(workerInfo.workerPIdFile);
            catch
            end
        end
    catch
    end

    if(exitMATLAB)


        cd(tempdir);
        try
            rmdir(poolRoot,'s');
        catch
        end
        exit('force');
    end
end
