function setupWorkers(modelName,designStudyStr,clientDataQ,runIds,reduceFcn,decimation)
    runner=simulink.multisim.internal.runner.MassiveSimRunnerWorker.getInstance();
    runner.reset(modelName,designStudyStr,clientDataQ,runIds,reduceFcn,decimation);
end