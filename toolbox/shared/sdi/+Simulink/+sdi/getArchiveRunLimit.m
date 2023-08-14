function count=getArchiveRunLimit()











    Simulink.sdi.internal.flushStreamingBackend();
    count=Simulink.sdi.Instance.engine.getArchiveRunLimit();
end

