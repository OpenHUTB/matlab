function unregisterWorkerStream(msg)



    if~isempty(eng.PCTRequestedSignalStreams)
        if isKey(eng.PCTRequestedSignalStreams,msg.WorkerSignalID)
            deleteDataByKey(eng.PCTRequestedSignalStreams,msg.WorkerSignalID);
            Simulink.HMI.setWorkerIsStreaming(msg.WorkerSignalID,false,getCount(eng.PCTRequestedSignalStreams));
        end
    end
end
