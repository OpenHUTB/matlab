function pushSignalDataFromWorker(requestMsg,startTime)




    if Simulink.sdi.internal.isParallelPoolSetup()
        Simulink.sdi.internal.flushStreamingBackend();
        eng=Simulink.sdi.Instance.engine;
        safeTransaction(eng,@locPushSignalDataFromWorker,eng,requestMsg,startTime);
    end
end


function locPushSignalDataFromWorker(eng,requestMsg,startTime)


    try
        vals=getSignalDataValues(eng,requestMsg.WorkerSignalID,startTime);
    catch me %#ok<NASGU>

        Simulink.sdi.internal.unregisterWorkerStream(requestMsg);
        return
    end


    if isempty(vals.Time)
        return
    end


    msg=requestMsg;
    msg.Type='stream_data';
    msg.Values=vals;
    msg.EndTime=vals.Time(end);
    Simulink.sdi.internal.sendMsgFromPCTWorker(msg,false);


    msg=rmfield(msg,'Values');
    if isempty(eng.PCTRequestedSignalStreams)
        eng.PCTRequestedSignalStreams=Simulink.sdi.Map(int32(0),?struct);
    end
    insert(eng.PCTRequestedSignalStreams,msg.WorkerSignalID,msg);
    Simulink.HMI.setWorkerIsStreaming(msg.WorkerSignalID,true,getCount(eng.PCTRequestedSignalStreams));
end
