function variableRegistryAndModel = getVariableRegistryAndModel( modelName )

arguments
    modelName( 1, 1 )string
end

variableRegistryFilePath = simulink.rapidaccelerator.internal.getVariableRegistryFilePath( modelName );

if ~exist( variableRegistryFilePath, "file" )
    error( message( 'SimulinkStandalone:ParameterTuning:VariableRegistryFileNotFound', modelName ) );
end

mf0XmlParser = mf.zero.io.XmlParser;
variableRegistry = mf0XmlParser.parseFile( variableRegistryFilePath );
variableRegistryAndModel = struct( 'variableRegistry', variableRegistry, 'model', mf0XmlParser.Model );
end

