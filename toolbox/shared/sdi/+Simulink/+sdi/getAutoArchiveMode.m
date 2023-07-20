function out=getAutoArchiveMode()








    Simulink.sdi.internal.flushStreamingBackend();
    out=Simulink.sdi.Instance.engine.getAutoArchiveMode();
end

