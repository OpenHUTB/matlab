function setAutoArchiveMode(state)







    Simulink.sdi.internal.flushStreamingBackend();
    Simulink.sdi.Instance.engine.setAutoArchiveMode(state);
end

