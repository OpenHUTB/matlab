function deleteWorker(obj,workerId)




    obj.getWorkers();
    if(obj.workerMap.isKey(workerId))
        worker=stm.internal.MRT.mrtpool.getWorkerInfo(obj.poolRoot,workerId);
        fid=fopen(worker.exitFile,'w');
        fclose(fid);
    end
end
