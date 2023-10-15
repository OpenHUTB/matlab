function variableRegistryFilePath = getVariableRegistryFilePath( modelName )

arguments
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

