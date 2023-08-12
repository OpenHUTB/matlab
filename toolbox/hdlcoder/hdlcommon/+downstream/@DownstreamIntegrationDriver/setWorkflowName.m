function setWorkflowName( obj, targetName )




switch targetName
case obj.FILWorkflowStr

fildir = fullfile( matlabroot, 'toolbox', 'shared', 'eda' );
if ~( license( 'test', 'EDA_Simulator_Link' ) && exist( fildir, 'dir' ) )
error( message( 'hdlcommon:hdlcommon:edasimulatorlinknotinstalled' ) );
end 



if isempty( obj.hFilWizardDlg )
obj.hFilWizardDlg = eda.FilAssistantDlg;
obj.hFilWizardDlg.IsInHDLWA = true;
obj.hFilBuildInfo = obj.hFilWizardDlg.BuildInfo;
obj.hFilBuildInfo.setOutputFolder( fullfile( obj.getProjectFolder, obj.filDir ) );
end 
case obj.USRPWorkflowStr

hasCommLicense = license( 'test', 'communication_toolbox' );
hasCommInstalled = exist( fullfile( matlabroot, 'toolbox', 'comm' ), 'dir' );
if ~hasCommLicense || ~hasCommInstalled
error( message( 'hdlcommon:workflow:CommTbxNotLicensed' ) );
end 
if ~isCommUSRPInstalled
error( message( 'hdlcommon:workflow:USRPPackageNotInstalled' ) );
end 

case obj.SDRWorkflowStr
checkSDRProductRequirements( true );
sdr.internal.hdlwa.driverSetWorkflowName( obj );

case obj.TurnkeyWorkflowStr

if obj.turnkeyboardloaded == false || obj.xpcboardloaded == true
if ~obj.turnkeyhandleset
obj.handleTurnkey = hdlturnkey.data.TurnkeyBoardList;
obj.turnkeyhandleset = true;
end 
obj.hAvailableBoardList = obj.handleTurnkey;
obj.turnkeyboardloaded = true;
obj.xpcboardloaded = false;
end 
case obj.XPCWorkflowStr
if obj.xpcboardloaded == false || obj.turnkeyboardloaded == true
if ~obj.xpchandleset
obj.handleXPC = hdlturnkey.plugin.SLRTBoardList;
obj.xpchandleset = true;
end 
obj.hAvailableBoardList = obj.handleXPC;
obj.xpcboardloaded = true;
obj.turnkeyboardloaded = false;
end 



if isempty( obj.hIP )
obj.hIP = hdlturnkey.ip.IPDriver( obj );
end 
case { obj.IPWorkflowStr, obj.DLWorkflowStr }



worklfowEnum = hdlcoder.Workflow.getWorkflowEnum( targetName );


if isempty( obj.hIP ) ||  ...
~isequal( obj.hIP.getWorkflowName, worklfowEnum )



obj.hIP = hdlturnkey.ip.IPDriver( obj, worklfowEnum );
end 
otherwise 
if obj.hWorkflowList.isInWorkflowList( targetName )

hWorkflow = obj.hWorkflowList.getWorkflow( targetName );
hWorkflow.setWorkflowName( obj, targetName );

elseif obj.isPluginWorkflow( targetName )
obj.pim.driverSetWorkflowName( targetName );
end 
end 

hOption = obj.getOption( 'Workflow' );
hOption.Value = targetName;


obj.SkipPlaceAndRoute = obj.isGenericWorkflow;
obj.SkipPreRouteTimingAnalysis = ~obj.isGenericWorkflow;

boardNameList = getBoardNameList( obj );
obj.setBoardName( boardNameList{ 1 } );
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpRGL9VX.p.
% Please follow local copyright laws when handling this file.

