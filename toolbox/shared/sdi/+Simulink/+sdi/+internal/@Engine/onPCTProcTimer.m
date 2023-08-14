function onPCTProcTimer(this)






    [runsToRequest,sigsToRequest,sigsToUnregister]=...
    sdi.Repository.popRequestSignalAndDataListFromWorker();


    enableDisablePCTTimer(this);


    pool=Simulink.sdi.internal.getCurrentParallelPool();
    if isempty(pool)
        this.PCTDataQueueFromWorker=[];
        this.PCTDataQueueToWorker=[];
        this.PCTRequestedSignalStreams=[];
        return
    end


    for idx=1:length(runsToRequest)
        Simulink.sdi.internal.requestSignalListFromWorker(runsToRequest(idx));
    end


    for idx=1:length(sigsToRequest)
        Simulink.sdi.internal.requestSignalDataFromWorker(sigsToRequest(idx),true);
    end


    for idx=1:length(sigsToUnregister)
        Simulink.sdi.internal.requestSignalDataFromWorker(sigsToUnregister(idx),false);
    end
end
