function pushSignalListFromWorker(requestMsg)




    if Simulink.sdi.internal.isParallelPoolSetup()
        Simulink.sdi.internal.flushStreamingBackend();
        eng=Simulink.sdi.Instance.engine;
        safeTransaction(eng,@locPushSignalListFromWorker,eng,requestMsg);
    end
end


function locPushSignalListFromWorker(~,requestMsg)
    msg=requestMsg;
    msg.Type='update_signals';
    Simulink.sdi.internal.sendMsgFromPCTWorker(msg,true);
end
