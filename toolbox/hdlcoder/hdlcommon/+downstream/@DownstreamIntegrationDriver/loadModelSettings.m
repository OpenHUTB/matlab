function loadModelSettings( obj, dutName )



if ( obj.isMLHDLC || obj.queryFlowOnly == downstream.queryflowmodesenum.VIVADOSYSGEN )
return 
end 

obj.errorModelSetting = false;
msg = {  };
obj.loadingFromModel = true;
modelName = bdroot( dutName );




boardSettingFailure = false;

if ~obj.isGenericWorkflow
try 
modelTargetPlatform = hdlget_param( modelName, 'TargetPlatform' );
if isempty( modelTargetPlatform )
modelTargetPlatform = obj.EmptyBoardStr;
end 
if ~strcmp( obj.get( 'Board' ), modelTargetPlatform )
obj.set( 'Board', modelTargetPlatform );
end 
catch me
msg1 = MException( message( 'hdlcommon:workflow:ApplyTargetPlatformSettingFromModel', me.message ) );
msg{ end  + 1 } = msg1;
obj.errorModelSetting = true;
boardSettingFailure = true;
end 
end 



toolSettingFailure = false;


if ~boardSettingFailure
toolName = hdlget_param( modelName, 'SynthesisTool' );
if strcmpi( toolName, 'Microsemi Libero SoC' )
toolName = 'Microchip Libero SoC';
end 




if strcmpi( toolName, 'Xilinx ISE' )
toolName = 'Xilinx ISE';
elseif strcmpi( toolName, 'Xilinx Vivado' )
toolName = 'Xilinx Vivado';
elseif strcmpi( toolName, 'Altera QUARTUS II' )
toolName = 'Altera QUARTUS II';
elseif strcmpi( toolName, 'Microchip Libero SoC' )
toolName = 'Microchip Libero SoC';
elseif strcmpi( toolName, 'Intel Quartus Pro' )
toolName = 'Intel Quartus Pro';
end 

try 
if ( ~isempty( toolName ) )
if ~strcmp( obj.get( 'Tool' ), toolName )
obj.set( 'Tool', toolName );
end 
end 
catch me
msg1 = MException( message( 'hdlcommon:workflow:ApplyToolDeviceSettingFromModel', me.message ) );
msg{ end  + 1 } = msg1;
obj.errorModelSetting = true;
toolSettingFailure = true;
end 
else 

toolSettingFailure = true;
end 





if ( ~obj.isToolEmpty && ~toolSettingFailure )
try 







if obj.isGenericWorkflow || ( obj.isIPWorkflow && obj.isGenericIPPlatform )
modelSynthesisToolChipFamily = hdlget_param( modelName, 'SynthesisToolChipFamily' );
if ( ~isempty( modelSynthesisToolChipFamily ) ) && ~strcmp( obj.get( 'Family' ), modelSynthesisToolChipFamily )
obj.set( 'Family', modelSynthesisToolChipFamily );
end 
modelSynthesisToolDeviceName = hdlget_param( modelName, 'SynthesisToolDeviceName' );
if ( ~isempty( modelSynthesisToolDeviceName ) ) && ~strcmp( obj.get( 'Device' ), modelSynthesisToolDeviceName )
obj.set( 'Device', modelSynthesisToolDeviceName );
end 
modelSynthesisToolPackageName = hdlget_param( modelName, 'SynthesisToolPackageName' );
if ( ~isempty( modelSynthesisToolPackageName ) ) && ~strcmp( obj.get( 'Package' ), modelSynthesisToolPackageName )
obj.set( 'Package', modelSynthesisToolPackageName );
end 
modelSynthesisToolSpeedValue = hdlget_param( modelName, 'SynthesisToolSpeedValue' );
if ( ~isempty( modelSynthesisToolSpeedValue ) ) && ~strcmp( obj.get( 'Speed' ), modelSynthesisToolSpeedValue )
obj.set( 'Speed', modelSynthesisToolSpeedValue );
end 
end 
catch me
msg1 = MException( message( 'hdlcommon:workflow:ApplyFPGADeviceSettingFromModel', me.message ) );
msg{ end  + 1 } = msg1;
obj.errorModelSetting = true;
end 
end 




if ~obj.errorModelSetting && ~strcmp( obj.get( 'Board' ), obj.EmptyBoardStr )

if ( obj.isIPCoreGen )
try 
modelReferenceDesign = hdlget_param( modelName, 'ReferenceDesign' );
if ( ~isempty( modelReferenceDesign ) )
if ~strcmp( obj.hIP.getReferenceDesign, modelReferenceDesign )
obj.hIP.setReferenceDesign( modelReferenceDesign );
end 
end 
modelRDParameterCellFormat = hdlget_param( modelName, 'ReferenceDesignParameter' );
if ~isempty( modelRDParameterCellFormat )
hRD = obj.hIP.getReferenceDesignPlugin;
if ~isempty( hRD )
hRD.setParameterCellFormat( modelRDParameterCellFormat );


obj.hIP.reloadReferenceDesignPlugin;
end 
end 
catch me
msg1 = MException( message( 'hdlcommon:workflow:ApplyRDSettingFromModel', me.message ) );
msg{ end  + 1 } = msg1;
obj.errorModelSetting = true;
end 
end 
end 




if ~strcmp( obj.get( 'Board' ), obj.EmptyBoardStr )
if obj.isTurnkeyWorkflow || obj.isXPCWorkflow || obj.isIPWorkflow
if ~obj.errorModelSetting
try 



if obj.isGenericIPPlatform
msg1 = obj.hTurnkey.updateInterfaceListWithModel;
if ~isempty( msg1 )
msg{ end  + 1 } = msg1;
obj.errorModelSetting = true;
end 
end 

msg1 = obj.loadInterfaceTable( dutName );
if ~isempty( msg1 )
msg = [ msg, msg1 ];
obj.errorModelSetting = true;
end 
catch me
msg1 = MException( message( 'hdlcommon:workflow:ApplyInterfaceTableSettingFromModel', me.message ) );
msg{ end  + 1 } = msg1;

obj.errorModelSetting = true;
end 
else 
msg1 = MException( message( 'hdlcommon:workflow:ApplyPreviousSettingErrorFromModel' ) );
msg{ end  + 1 } = msg1;
end 
end 
end 

if ~obj.errorModelSetting && ~strcmp( obj.get( 'Board' ), obj.EmptyBoardStr )
if ( obj.isIPCoreGen || obj.isXPCWorkflow )
if ~downstream.tool.isDUTTopLevel( dutName ) && ~downstream.tool.isDUTModelReference( dutName )
try 
modelSyncMode = hdlget_param( dutName, 'ProcessorFPGASynchronization' );
if ( ~isempty( modelSyncMode ) )
if ~strcmp( obj.get( 'ExecutionMode' ), modelSyncMode )
obj.set( 'ExecutionMode', modelSyncMode );
end 
end 
catch me
msg1 = MException( message( 'hdlcommon:workflow:ApplySyncModeSettingFromModel', me.message ) );
msg{ end  + 1 } = msg1;
obj.errorModelSetting = true;
end 
end 
end 
end 





if ~boardSettingFailure
try 
targetFrequency = hdlget_param( modelName, 'TargetFrequency' );



if obj.isIPCoreGen
hRD = obj.hIP.getReferenceDesignPlugin;
if ~isempty( hRD )
maxFrqlimitRD = hRD.hClockModule.ClockMaxMHz;
limit = adjustDeviceFrequencyLimit( obj );
if ( maxFrqlimitRD ~= limit )
warning( message( 'hdlcommon:workflow:LimitMaxfreqAMandFDCOverEthernet' ) );
end 
if ( targetFrequency > limit )
targetFrequency = limit;
end 
end 
end 

if ( targetFrequency ~= 0 && targetFrequency ~= obj.getTargetFrequency )
obj.setTargetFrequency( targetFrequency );
end 
catch me
msg1 = MException( message( 'hdlcommon:workflow:ApplyTargetFrequencySettingFromModel', me.message ) );
msg{ end  + 1 } = msg1;
obj.errorModelSetting = true;
end 
end 



if ( obj.isIPCoreGen )
if ~downstream.tool.isDUTTopLevel( dutName ) && ~downstream.tool.isDUTModelReference( dutName )
try 
ipCoreName = hdlget_param( dutName, 'IPCoreName' );
if ( ~isempty( ipCoreName ) )
if ~strcmp( obj.hIP.getIPCoreName, ipCoreName )
obj.hIP.setIPCoreName( ipCoreName );
end 
end 
catch me
msg1 = MException( message( 'hdlcommon:workflow:ApplyIPCoreSettingsFromModel', me.message ) );
msg{ end  + 1 } = msg1;
obj.errorModelSetting = true;
end 
try 

ipCoreVersion = hdlget_param( dutName, 'IPCoreVersion' );
if ( ~isempty( ipCoreVersion ) )
if ~strcmp( obj.hIP.getIPCoreVersion, ipCoreVersion )
obj.hIP.setIPCoreVersion( ipCoreVersion );
end 
end 
catch me
msg1 = MException( message( 'hdlcommon:workflow:ApplyIPCoreSettingsFromModel', me.message ) );
msg{ end  + 1 } = msg1;
obj.errorModelSetting = true;
end 
try 

AXISlaveIDWidth = hdlget_param( dutName, 'AXI4SlaveIDWidth' );
if ( ~isempty( AXISlaveIDWidth ) )
if ~strcmp( obj.hIP.getIDWidth, AXISlaveIDWidth )
obj.hIP.setIDWidth( AXISlaveIDWidth );
end 
end 
catch me
msg1 = MException( message( 'hdlcommon:workflow:ApplyIPCoreSettingsFromModel', me.message ) );
msg{ end  + 1 } = msg1;
obj.errorModelSetting = true;
end 
try 
bufferSize = hdlget_param( dutName, 'IPDataCaptureBufferSize' );
if ( ~isempty( bufferSize ) )
if ~strcmp( obj.hIP.getIPDataCaptureBufferSize, bufferSize )
obj.hIP.setIPDataCaptureBufferSize( bufferSize );
end 
end 
catch me
msg1 = MException( message( 'hdlcommon:workflow:ApplyIPCoreSettingsFromModel', me.message ) );
msg{ end  + 1 } = msg1;
obj.errorModelSetting = true;
end 
try 
sequenceDepth = hdlget_param( dutName, 'IPDataCaptureSequenceDepth' );
if ( ~isempty( sequenceDepth ) )
if ~strcmp( obj.hIP.getIPDataCaptureSequenceDepth, sequenceDepth )
obj.hIP.setIPDataCaptureSequenceDepth( sequenceDepth );
end 
end 
catch me
msg1 = MException( message( 'hdlcommon:workflow:ApplyIPCoreSettingsFromModel', me.message ) );
msg{ end  + 1 } = msg1;
obj.errorModelSetting = true;
end 
try 
setCaptureControl = hdlget_param( dutName, 'IncludeDataCaptureControlLogicEnable' );
if strcmp( setCaptureControl, 'on' )
captureControlEnable = 1;
else 
captureControlEnable = 0;
end 
if ( ~isempty( setCaptureControl ) )
if ~strcmp( obj.hIP.getIncludeDataCaptureControlLogicEnable, captureControlEnable )
obj.hIP.setIncludeDataCaptureControlLogicEnable( captureControlEnable );
end 
end 
catch me
msg1 = MException( message( 'hdlcommon:workflow:ApplyIPCoreSettingsFromModel', me.message ) );
msg{ end  + 1 } = msg1;
obj.errorModelSetting = true;
end 
try 
additionalSourceFile = hdlget_param( dutName, 'IPCoreAdditionalFiles' );
if ( ~isempty( additionalSourceFile ) )
if ~strcmp( obj.hIP.getIPCoreCustomFile, additionalSourceFile )
obj.hIP.setIPCoreCustomFile( additionalSourceFile );
end 
end 
catch me
msg1 = MException( message( 'hdlcommon:workflow:ApplyIPCoreSettingsFromModel', me.message ) );
msg{ end  + 1 } = msg1;
obj.errorModelSetting = true;
end 
try 
setAXI4RegisterReadback = hdlget_param( dutName, 'AXI4RegisterReadback' );

if strcmp( setAXI4RegisterReadback, 'on' )
enableAXI4RegisterReadback = 1;
else 
enableAXI4RegisterReadback = 0;
end 

if ( ~isempty( setAXI4RegisterReadback ) )
if ( obj.hIP.getAXI4ReadbackEnable ~= enableAXI4RegisterReadback )
obj.hIP.setAXI4ReadbackEnable( enableAXI4RegisterReadback );
end 
end 
catch me
msg1 = MException( message( 'hdlcommon:workflow:ApplyIPCoreSettingsFromModel', me.message ) );
msg{ end  + 1 } = msg1;
obj.errorModelSetting = true;
end 
try 
setAXI4Slave = hdlget_param( dutName, 'GenerateDefaultAXI4Slave' );
if strcmp( setAXI4Slave, 'on' )
enableAXI4Slave = 1;
else 
enableAXI4Slave = 0;
end 

if ( ~isempty( setAXI4Slave ) )
if ( obj.hIP.getAXI4SlaveEnable ~= enableAXI4Slave )
obj.hIP.setAXI4SlaveEnable( enableAXI4Slave );
end 
end 
catch me
msg1 = MException( message( 'hdlcommon:workflow:ApplyIPCoreSettingsFromModel', me.message ) );
msg{ end  + 1 } = msg1;
obj.errorModelSetting = true;
end 
try 
exposeDUTClockEnable = hdlget_param( dutName, 'ExposeDUTClockEnablePort' );
if strcmp( exposeDUTClockEnable, 'on' )
DUTClockEnable = 1;
else 
DUTClockEnable = 0;
end 

if ( ~isempty( exposeDUTClockEnable ) )
if ( obj.hIP.getDUTClockEnable ~= DUTClockEnable )
obj.hIP.setDUTClockEnable( DUTClockEnable );
end 
end 
catch me
msg1 = MException( message( 'hdlcommon:workflow:ApplyIPCoreSettingsFromModel', me.message ) );
msg{ end  + 1 } = msg1;
obj.errorModelSetting = true;
end 
try 
exposeDUTCEOut = hdlget_param( dutName, 'ExposeDUTCEOutPort' );
if strcmp( exposeDUTCEOut, 'on' )
DUTCEOut = 1;
else 
DUTCEOut = 0;
end 

if ( ~isempty( exposeDUTCEOut ) )
if ( obj.hIP.getDUTCEOut ~= DUTCEOut )
obj.hIP.setDUTCEOut( DUTCEOut );
end 
end 
catch me
msg1 = MException( message( 'hdlcommon:workflow:ApplyIPCoreSettingsFromModel', me.message ) );
msg{ end  + 1 } = msg1;
obj.errorModelSetting = true;
end 
try 
setAXI4SlavePortToPipelineRegisterRatio = hdlget_param( dutName, 'AXI4SlavePortToPipelineRegisterRatio' );
if ( ~isempty( setAXI4SlavePortToPipelineRegisterRatio ) )
if ~strcmp( obj.hIP.getInsertAXI4PipelineRegisterEnable, setAXI4SlavePortToPipelineRegisterRatio )
obj.hIP.setInsertAXI4PipelineRegisterEnable( setAXI4SlavePortToPipelineRegisterRatio );
end 
end 
catch me
msg1 = MException( message( 'hdlcommon:workflow:ApplyIPCoreSettingsFromModel', me.message ) );
msg{ end  + 1 } = msg1;
obj.errorModelSetting = true;
end 
end 
end 



try 
obj.loadGenerateHDLSettingsFromModel( modelName );
catch me
msg1 = MException( message( 'hdlcommon:workflow:ApplyGenerateHDLSettingFromModel', me.message ) );
msg{ end  + 1 } = msg1;
obj.errorModelSetting = true;
end 



if ~obj.isIPCoreGen && ~obj.isToolEmpty
try 
synthesisProjectAdditionalFiles = hdlget_param( modelName, 'SynthesisProjectAdditionalFiles' );
if ( ~isempty( synthesisProjectAdditionalFiles ) )
obj.setCustomHDLFile( synthesisProjectAdditionalFiles );
end 
catch me
msg1 = MException( message( 'hdlcommon:workflow:ApplySynthesisProjectAdditionalFilesFromModel', me.message ) );
msg{ end  + 1 } = msg1;
obj.errorModelSetting = true;
end 
end 

obj.loadingFromModel = false;
obj.updateCodegenAndPrjDir;
obj.emitLoadingErrorMsg( modelName, msg );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpX1mEyY.p.
% Please follow local copyright laws when handling this file.

