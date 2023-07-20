function postPoolCreation(pool)










    try
        poolType=iGetPoolType(pool);
        poolSize=pool.NumWorkers;
        iLog(poolType,poolSize);
    catch err
        dctSchedulerMessage(1,"Failed to log pool creation: %s",err.getReport());
    end

end



function poolType=iGetPoolType(pool)


    if isa(pool,"parallel.ThreadPool")
        poolType="Threads";
    else
        poolType=string(pool.Cluster.Type);
    end
end



function iLog(poolType,poolSize)




    dataId=matlab.ddux.internal.DataIdentification("DM",...
    "DM_POOL","DM_POOL_CREATE");
    matlab.ddux.internal.logData(dataId,...
    "poolType",poolType,"numWorkers",int64(poolSize));
end
