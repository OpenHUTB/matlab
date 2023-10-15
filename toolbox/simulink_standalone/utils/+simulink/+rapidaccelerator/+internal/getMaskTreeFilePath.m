function maskTreeFilePath = getMaskTreeFilePath( modelName )

arguments
    modelName( 1, 1 )string
end

if ~Simulink.isRaccelDeployed
    folders = Simulink.filegen.internal.FolderConfiguration( modelName, true, false );
    buildDir = folders.RapidAccelerator.absolutePath( 'ModelCode' );


    modelName = convertStringsToChars( modelName );

    maskTreeFilePath = rapid_accel_target_utils(  ...
        'get_mask_tree_file',  ...
        modelName,  ...
        buildDir ...
        );
else
    modelInterface = Simulink.RapidAccelerator.getStandaloneModelInterface( modelName );
    modelInterface.initializeForDeployment(  );
    maskTreeFilePath = modelInterface.getMaskTreeFile(  );
end
end


