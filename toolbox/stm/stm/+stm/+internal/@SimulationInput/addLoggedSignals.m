function simIn=addLoggedSignals(simIn,blockPath,portIdx)






    loggingSpec=simIn.LoggingSpecification;
    if isempty(loggingSpec)
        loggingSpec=Simulink.Simulation.LoggingSpecification;
    end
    loggingSpec.addSignalsToLog(blockPath,portIdx);
    simIn.LoggingSpecification=loggingSpec;

end
