function[runID,runIndex,signalIDs]=copyRun(varargin)







    Simulink.sdi.internal.flushStreamingBackend();
    [runID,runIndex,signalIDs]=Simulink.sdi.Instance.engine.copyRun(varargin{:});
end
