function streamAllPendingSignalsFromWorker()

    if Simulink.sdi.internal.isParallelPoolSetup()
        Simulink.sdi.internal.flushStreamingBackend();
        eng=Simulink.sdi.Instance.engine;
        if~isempty(eng.PCTRequestedSignalStreams)
            safeTransaction(eng,@locStreamAllPendingSignalsFromWorker,eng);
        end
    end
end


function locStreamAllPendingSignalsFromWorker(eng)
    sigMap=eng.PCTRequestedSignalStreams;
    numSigs=getCount(sigMap);
    for idx=1:numSigs
        msg=getDataByIndex(sigMap,idx);

        startTime=msg.EndTime;
        if isfinite(startTime)
            startTime=startTime+eps;
        end
        Simulink.sdi.internal.pushSignalDataFromWorker(msg,startTime);
    end
end
