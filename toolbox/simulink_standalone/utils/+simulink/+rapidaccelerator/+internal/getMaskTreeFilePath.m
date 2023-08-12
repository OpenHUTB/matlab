function maskTreeFilePath = getMaskTreeFilePath( modelName )




R36
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
% Decoded using De-pcode utility v1.2 from file /tmp/tmpWWDRm3.p.
% Please follow local copyright laws when handling this file.

