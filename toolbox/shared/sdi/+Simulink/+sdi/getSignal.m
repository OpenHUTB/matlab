function signal=getSignal(signalID)    Simulink.sdi.internal.flushStreamingBackend();
    signal=Simulink.sdi.Instance.engine.getSignalObject(signalID);
end