function populateSimIn(runTestConfig,simInStruct,simWatcher)

    import stm.internal.SimulationInput;


    parsim=stm.internal.SimulationInput(simInStruct,runTestConfig,simWatcher);
    runTestConfig.SimulationInput=simWatcher.coverage.getSimInput(runTestConfig.SimulationInput,simWatcher.fastRestart);
    parsim.applyIterationModelParameters;
    parsim.applySUTSettings;
    parsim.applyParameterOverrides;
    try

        parsim.applyInputs;
    catch me

        parsim.cleanupSignalBuilder(simWatcher);
        if slfeature('STMTestSequenceScenario')
            parsim.cleanupTestSequenceScenario(simWatcher);
        end
        throw(me)
    end





    if~(simWatcher.fastRestart&&simInStruct.IterationId>0&&slfeature('STMSimulationInputArray')>0)
        parsim.applyOutputSettings;
    end

    parsim.applyLoggingSettings;
    parsim.applyIterationVariableParameters;
end
