function cleanupWorkerAfterParsim()

    try
        isPCTWorker=~isempty(getCurrentWorker());
    catch me %#ok<NASGU>
        isPCTWorker=false;
    end

    if isPCTWorker
        Simulink.sdi.internal.flushStreamingBackend();
        drawnow;
        if~Simulink.sdi.internal.getSetWorkerRunSentToClient()
            Simulink.sdi.internal.clearRepoOnWorker();
        end
        Simulink.sdi.internal.getSetWorkerRunSentToClient(false);
    end
end
