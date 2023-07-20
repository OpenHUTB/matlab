function runID=getRunIDByIndex(index)




    Simulink.sdi.internal.flushStreamingBackend();
    runID=Simulink.sdi.Instance.engine.getRunIDByIndex(index);
end