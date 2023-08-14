


function newSimInputs=resetLoggingSpec(loggedSignalsUnionMap,actualSimulationInputs)





    newSimInputs=actualSimulationInputs;

    if isempty(actualSimulationInputs)
        return;
    end

    sigs=values(loggedSignalsUnionMap);
    logSpecNoneLogged=Simulink.Simulation.LoggingSpecification;
    for jdx=1:numel(sigs)
        logSpecNoneLogged.addSignalsToLog(sigs{jdx});
    end

    allModels={actualSimulationInputs.ModelName};
    loggingSpecMap=MultiSim.internal.getLoggingSpecificationForModels(allModels);

    for idx=1:numel(actualSimulationInputs)
        logSpec=actualSimulationInputs(idx).LoggingSpecification;
        if isempty(logSpec)
            modelName=actualSimulationInputs(idx).ModelName;
            defaultLogSpec=loggingSpecMap(modelName);
            if isempty(defaultLogSpec)
                defaultLogSpec=logSpecNoneLogged;
            end
            newSimInputs(idx).LoggingSpecification=defaultLogSpec;
        end
    end
end

