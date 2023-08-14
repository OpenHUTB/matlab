function status=checkWorker(poolRoot,workerId)




    status=true;
    workerInfo=stm.internal.MRT.mrtpool.getWorkerInfo(poolRoot,workerId);
    if(~exist(workerInfo.startedFile,'file')||~exist(workerInfo.runningFile,'file'))
        status=false;
        return;
    end

    if(~exist(workerInfo.todoFolder,'dir')||~exist(workerInfo.doneFolder,'dir'))
        status=false;
        return;
    end
end
