function[runIDs,runIndices]=createRunsFromSimulationOutput(simOutput)

    eng=Simulink.sdi.Instance.engine;
    runName=eng.runNameTemplate;
    [runIDs,runIndices]=Simulink.sdi.createRun(runName,'vars',simOutput);
end