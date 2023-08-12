function utilParseReferenceDesign( mdladvObj, hDI )




RDTaskID = 'com.mathworks.HDL.SetTargetReferenceDesign';
inputParams = mdladvObj.getInputParameters( RDTaskID );
rfNameOption = utilGetInputParameter( inputParams, DAStudio.message( 'HDLShared:hdldialog:HDLWAReferenceDesign' ) );
rfVersionOption = utilGetInputParameter( inputParams, DAStudio.message( 'HDLShared:hdldialog:HDLWARDToolVersion' ) );
rfIgnoreOption = utilGetInputParameter( inputParams, DAStudio.message( 'HDLShared:hdldialog:HDLWARDToolVersionIgnore' ) );

if ~strcmp( rfNameOption.Value, hDI.hIP.getReferenceDesign )
hDI.hIP.setReferenceDesign( rfNameOption.Value );
end 
if ~strcmp( rfVersionOption.Value, hDI.hIP.getRDToolVersion )
hDI.hIP.setRDToolVersion( rfVersionOption.Value );
end 
if ~strcmp( rfIgnoreOption.Value, hDI.hIP.getIgnoreRDToolVersionMismatch )
hDI.hIP.setIgnoreRDToolVersionMismatch( rfIgnoreOption.Value );
end 

system = mdladvObj.System;
hModel = bdroot( system );
hDI.saveRDSettingToModel( hModel, hDI.hIP.getReferenceDesign );

end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpw2xpmf.p.
% Please follow local copyright laws when handling this file.

