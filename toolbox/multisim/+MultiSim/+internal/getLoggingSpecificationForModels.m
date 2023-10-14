function loggingSpecMap = getLoggingSpecificationForModels( models )

arguments
    models string
end

loggingSpecMap = containers.Map;
uniqueModels = unique( models );
for model = uniqueModels
    modelLoggingInfo = Simulink.SimulationData.ModelLoggingInfo.createFromModel( convertStringsToChars( model ) );

    logSpec = Simulink.Simulation.LoggingSpecification.empty;
    if ~isempty( modelLoggingInfo.Signals )
        logSpec = Simulink.Simulation.LoggingSpecification;
        logSpec.addSignalsToLog( modelLoggingInfo.Signals );
    end
    loggingSpecMap( model ) = logSpec;
end
end

