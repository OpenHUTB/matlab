function run=getRun(runID)







    Simulink.sdi.internal.flushStreamingBackend();
    run=Simulink.sdi.Instance.engine.getRun(runID);
end
