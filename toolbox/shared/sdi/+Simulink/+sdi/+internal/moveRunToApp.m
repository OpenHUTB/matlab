function moveRunToApp(runID,newAppName,varargin)
    Simulink.sdi.internal.flushStreamingBackend();
    eng=Simulink.sdi.Instance.engine;
    moveRunToApp(eng,runID,newAppName,varargin{:});
end
