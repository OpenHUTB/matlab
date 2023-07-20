function requestSignalListFromWorker(runID)




    eng=Simulink.sdi.Instance.engine;



    try
        [workerInstanceID,workerRunID,bIsStreaming,bHasSignals]=...
        getWorkerRunSettings(eng.sigRepository,runID);
        if~bIsStreaming||bHasSignals
            return
        end
    catch me %#ok<NASGU>

        return
    end


    if~isempty(eng.PCTDataQueueToWorker)&&isKey(eng.PCTDataQueueToWorker,workerInstanceID)
        msg.Type='request_signals';
        msg.WorkerInstanceID=workerInstanceID;
        msg.WorkerRunID=workerRunID;
        msg.ClientRunID=runID;

        dc=getDataByKey(eng.PCTDataQueueToWorker,workerInstanceID);
        send(dc,msg);
    end
end
