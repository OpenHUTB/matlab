function discardDataFromPriorSessions()

    eng=Simulink.sdi.Instance.engine;
    eng.sigRepository.purgeDeletedRuns();
    Simulink.AsyncQueue.DataType.clearCache();
end