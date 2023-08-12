function parameterTuningManager = getParameterTuningManager( modelName )



R36
modelName( 1, 1 )string
end 

variableRegistryAndModel = simulink.rapidaccelerator.internal.getVariableRegistryAndModel( modelName );
parameterTuningManager = simulink.rapidaccelerator.internal.ParameterTuningManager( variableRegistryAndModel.variableRegistry );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmptEqu_l.p.
% Please follow local copyright laws when handling this file.

