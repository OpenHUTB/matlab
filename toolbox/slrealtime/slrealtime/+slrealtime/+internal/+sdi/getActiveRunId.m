function runId=getActiveRunId(modelName,targetName)
















    eng=Simulink.sdi.Instance.engine;
    Simulink.HMI.partialFlushWorkerQueueForRunCreation(modelName,targetName);
    runId=eng.getCurrentStreamingRunID(modelName,targetName);
end
