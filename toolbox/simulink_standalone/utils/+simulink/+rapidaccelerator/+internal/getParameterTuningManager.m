function parameterTuningManager = getParameterTuningManager( modelName )

arguments
    modelName( 1, 1 )string
end

variableRegistryAndModel = simulink.rapidaccelerator.internal.getVariableRegistryAndModel( modelName );
parameterTuningManager = simulink.rapidaccelerator.internal.ParameterTuningManager( variableRegistryAndModel.variableRegistry );
end
