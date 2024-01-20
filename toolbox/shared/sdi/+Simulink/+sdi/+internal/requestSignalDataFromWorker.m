function requestSignalDataFromWorker(sigID,bRequest)

    eng=Simulink.sdi.Instance.engine;

    try
        [workerInstanceID,workerSigID]=...
        getWorkerSignalSettings(eng.sigRepository,sigID);
        if~workerSigID
            return
        end
    catch me %#ok<NASGU>

        return
    end
   if~isempty(eng.PCTDataQueueToWorker)&&isKey(eng.PCTDataQueueToWorker,workerInstanceID)
        msg.Type='request_streaming';
        msg.WorkerInstanceID=workerInstanceID;
        msg.WorkerSignalID=workerSigID;
        msg.ClientSignalID=sigID;
        msg.RequestData=bRequest;
        dc=getDataByKey(eng.PCTDataQueueToWorker,workerInstanceID);
        send(dc,msg);
    end
end
