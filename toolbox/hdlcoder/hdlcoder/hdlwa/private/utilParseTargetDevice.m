function isReset = utilParseTargetDevice( mdladvObj, hDI )




hdlwaDriver = hdlwa.hdlwaDriver.getHDLWADriverObj;
targetObj = hdlwaDriver.getTaskObj( 'com.mathworks.HDL.SetTargetDevice' );


targetInputParams = mdladvObj.getInputParameters( targetObj.MAC );
workflowOption = targetInputParams{ 1 };
boardOption = targetInputParams{ 2 };
toolOption = targetInputParams{ 3 };
familyOption = targetInputParams{ 4 };
deviceOption = targetInputParams{ 5 };
packageOption = targetInputParams{ 6 };
speedOption = targetInputParams{ 7 };
folderOption = targetInputParams{ 8 };

isReset = false;

try 



if hDI.isNoToolAvailable( hDI.get( 'Tool' ) ) && ~hDI.isNoToolAvailable( toolOption.Value )
oldToolValue = toolOption.Value;

utilAdjustTargetDevice( mdladvObj, hDI );

utilUpdateInterfaceTable( mdladvObj, hDI );

utilAdjustWorkflowParameter( mdladvObj, hDI );


error( message( 'hdlcoder:workflow:ToolNotAvailable', oldToolValue ) );
end 



if ~hDI.isNoToolAvailable( hDI.get( 'Tool' ) ) && hDI.isNoToolAvailable( toolOption.Value )

utilAdjustTargetDevice( mdladvObj, hDI );

utilUpdateInterfaceTable( mdladvObj, hDI );

utilAdjustWorkflowParameter( mdladvObj, hDI );
end 


toolOption.Entries = hDI.set( 'Tool' );


if ~strcmp( workflowOption.Value, hDI.get( 'Workflow' ) )
hDI.set( 'Workflow', workflowOption.Value );

hDI.hTurnkey.hTable.cleanInterfaceTable;
hDI.hTurnkey.hTable.cleanPIR;
end 
if ~strcmp( boardOption.Value, hDI.get( 'Board' ) )
hDI.set( 'Board', boardOption.Value );

hDI.hTurnkey.hTable.cleanInterfaceTable;
hDI.hTurnkey.hTable.cleanPIR;
end 
if ~strcmp( toolOption.Value, hDI.get( 'Tool' ) )
hDI.set( 'Tool', toolOption.Value );
end 
if ~strcmp( familyOption.Value, hDI.get( 'Family' ) )
hDI.set( 'Family', familyOption.Value );
end 
if ~strcmp( deviceOption.Value, hDI.get( 'Device' ) )
hDI.set( 'Device', deviceOption.Value );
end 
if ~strcmp( packageOption.Value, hDI.get( 'Package' ) )
hDI.set( 'Package', packageOption.Value );
end 
if ~strcmp( speedOption.Value, hDI.get( 'Speed' ) )
hDI.set( 'Speed', speedOption.Value );
end 
if ~strcmp( folderOption.Value, hDI.getProjectFolder )
hDI.setProjectFolder( folderOption.Value );
end 


system = mdladvObj.System;
sobj = get_param( bdroot( system ), 'Object' );
configSet = sobj.getActiveConfigSet;
hObj = gethdlcconfigset( configSet );
hModel = bdroot( system );

curRtlDir = hdlget_param( hModel, 'TargetDirectory' );
if ~strcmp( curRtlDir, hDI.getFullHdlsrcDir )
hObj.getCLI.TargetDirectory = hDI.getFullHdlsrcDir;
hdlset_param( hModel, 'TargetDirectory', hDI.getFullHdlsrcDir );
end 

if ~hDI.isToolEmpty && ~hDI.isFILWorkflow
hDI.setProjectPath( hDI.getFullFPGADir );
end 

hDI.updateCodegenAndPrjDir;

if ( strcmpi( toolOption.value, 'No synthesis tool specified' ) || strcmpi( toolOption.value, 'No synthesis tool available on system path' ) )
tool = '';
else 
tool = toolOption.value;
end 

hDI.savetargetDeviceSettingToModel( hModel, workflowOption.Value, boardOption.Value, tool, familyOption.Value, deviceOption.Value, packageOption.Value, speedOption.Value );

catch ME


targetObj.reset
isReset = true;

errorMsg = sprintf( [ 'Error occurred in Task 1.1 when loading Restore Point.\n',  ...
'The error message is:\n%s\n',  ...
'Please reassign target device information.' ],  ...
ME.message );
hf = errordlg( errorMsg, 'Error', 'modal' );

set( hf, 'tag', 'Load Target Device error dialog' );
setappdata( hf, 'MException', ME );
end 


end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpydkXsE.p.
% Please follow local copyright laws when handling this file.

