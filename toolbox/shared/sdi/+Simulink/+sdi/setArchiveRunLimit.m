function setArchiveRunLimit(count)










    Simulink.sdi.internal.flushStreamingBackend();
    Simulink.sdi.Instance.engine.setArchiveRunLimit(count);
end

