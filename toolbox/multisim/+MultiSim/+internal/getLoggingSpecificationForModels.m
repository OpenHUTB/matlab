function loggingSpecMap = getLoggingSpecificationForModels( models )






R36
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
% Decoded using De-pcode utility v1.2 from file /tmp/tmp9TcAys.p.
% Please follow local copyright laws when handling this file.

