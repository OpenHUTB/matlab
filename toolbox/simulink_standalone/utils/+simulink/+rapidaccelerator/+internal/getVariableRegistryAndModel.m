function variableRegistryAndModel = getVariableRegistryAndModel( modelName )





R36
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

% Decoded using De-pcode utility v1.2 from file /tmp/tmpjmEn0P.p.
% Please follow local copyright laws when handling this file.

