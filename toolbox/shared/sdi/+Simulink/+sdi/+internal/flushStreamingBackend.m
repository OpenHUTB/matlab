function flushStreamingBackend()

    eng=Simulink.sdi.Instance.engine;
    if isa(eng.sigRepository,'sdi.Repository')
        Simulink.HMI.synchronouslyFlushWorkerQueue(eng.sigRepository);
        Simulink.sdi.checkPendingRunDelete();
    else
        Simulink.HMI.synchronouslyFlushWorkerQueue();
    end
end
