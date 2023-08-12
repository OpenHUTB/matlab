function variableRegistryFilePath = getVariableRegistryFilePath( modelName )



R36
modelName( 1, 1 )string
end 

if Simulink.isRaccelDeployed
modelInterface = Simulink.RapidAccelerator.getStandaloneModelInterface( modelName );
modelInterface.initializeForDeployment(  );
variableRegistryFilePath = modelInterface.getVariableRegistryFilePath(  );
else 
folders = Simulink.filegen.internal.FolderConfiguration( modelName );
buildDir = folders.RapidAccelerator.absolutePath( 'ModelCode' );
variableRegistryFilePath = fullfile( buildDir, modelName + "_variable_registry.xml" );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpyTOo56.p.
% Please follow local copyright laws when handling this file.

