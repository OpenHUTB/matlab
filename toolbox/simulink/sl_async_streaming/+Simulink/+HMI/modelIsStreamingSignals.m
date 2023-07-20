





function isStreaming=modelIsStreamingSignals(mdl)
    qs=Simulink.AsyncQueue.Queue.getAllQueues(mdl);
    isStreaming=~isempty(qs)||...
    Simulink.AsyncQueue.Queue.hasPendingQueues(mdl);
end
