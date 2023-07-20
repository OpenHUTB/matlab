function loadMessgeData(obj)



    if(isempty(obj.msgData))
        poolInfo=stm.internal.MRT.mrtpool.getWorkerInfo();
        obj.msgData=load(poolInfo.hostMsgCatalog);
    end
end
