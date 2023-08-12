function preCompileCallback( modelName, isModelReference, varargin )




cs = getActiveConfigSet( modelName );

checkSimModes( modelName, isModelReference );
checkTaskManagerSemantics( modelName, isModelReference );

if codertarget.data.isParameterInitialized( cs, 'TargetHardware' )
board = codertarget.data.getParameterValue( cs, 'TargetHardware' );
else 
board = get_param( modelName, 'HardwareBoard' );
end 

device = get_param( modelName, 'ProdHWDeviceType' );


isProcCompat = codertarget.targethardware.isESBCompatible( cs, 1 );
isFPGACompat = codertarget.targethardware.isESBCompatible( cs, 2 );
isNone = isequal( board, 'None' );
isFPGAModel = isNone && contains( device, 'ASIC/FPGA' );

if isNone
if ~isFPGAModel
warning( message( 'soc:scheduler:NotASICFPGADevice',  ...
modelName, board, device ) );
end 
return ;
end 

if ~isModelReference
if ~isProcCompat && ~isFPGACompat
error( message( 'soc:scheduler:UnsupportedBoard', modelName, board ) );
end 
if isequal( get_param( modelName, 'EnableAccessToBaseWorkspace' ), 'off' )
error( message( 'soc:scheduler:BaseWorkSpaceAccess' ) );
end 
setSeedForRandomizingSimulation( modelName );
if ~isFPGAModel, setKernelLatencyInWorkspace( modelName );end 
setWarningsInitState;
else 
if ~isFPGAModel && ~isProcCompat
warning( message( 'soc:scheduler:UnsupportedBoard', modelName, board ) );
end 
end 



soc.internal.ESBRegistry.manageInstance( 'destroy', modelName, 'ESB' );

if isModelReference
soc.blocks.proxyTaskData( 'init', modelName );
end 

if ~isModelReference && soc.internal.taskmanager.isUsingScheduleEditor( modelName )
synchronizeScheduleEditorSchedule( modelName );
end 
end 


function setKernelLatencyInWorkspace( modelName )
hCS = getActiveConfigSet( modelName );
mdlWks = get_param( modelName, 'ModelWorkspace' );
kernelLatency = 0.0;
if codertarget.data.isValidParameter( hCS, 'OS.KernelLatency' )
kernelLatency = codertarget.data.getParameterValue( hCS, 'OS.KernelLatency' );
end 
origDirtyFlag = get_param( modelName, 'Dirty' );
assignin( mdlWks, 'mwTaskManagerKernelLatency', kernelLatency );
set_param( modelName, 'Dirty', origDirtyFlag )
end 


function setSeedForRandomizingSimulation( modelName )
hCS = getActiveConfigSet( modelName );
if ~codertarget.data.isValidParameter( hCS,  ...
DAStudio.message( 'codertarget:ui:SetSeedStorage' ) )
return ;
end 
seedVal = codertarget.data.getParameterValue( hCS,  ...
DAStudio.message( 'codertarget:ui:RNGSeedStorage' ) );
if isequal( seedVal, 'default' )

elseif iscvar( seedVal )

seedVar = seedVal;
if ~evalin( 'base', [ 'exist(''', seedVar, ''')' ] )
error( message( 'codertarget:ui:SeedVariableUndefined',  ...
seedVar, seedVar ) );
end 
seedVal = evalin( 'base', seedVar );
if isequal( seedVal, 'default' )

else 
seedRaw = seedVal;
seedVal = uint64( seedVal );
if isempty( seedVal ) || ~isscalar( seedVal ) || ~isreal( seedVal ) ||  ...
seedVal < 0 || seedVal > 4294967295 || ~isequal( seedVal, seedRaw )
error( message( 'codertarget:ui:SeedVariableInvalid', seedVar ) );
end 
end 
else 

seedVal = uint32( str2double( seedVal ) );
end 
rng( seedVal );
end 


function setWarningsInitState


id = 'SimulinkDiscreteEvent:MatlabEventSystem:DefaultOutputConnection';
prefName = [ 'Warnings', strrep( id, ':', '' ) ];
prefName = prefName( 1:63 );
warningAtStart = warning( 'query', id );
soc.internal.setPreference( prefName, warningAtStart.state );
warning( 'off', id );
end 


function checkSimModes( mdl, isModelReference )

simStatus = get_param( mdl, 'SimulationStatus' );
simMode = get_param( mdl, 'SimulationMode' );
stfFile = get_param( mdl, 'SystemTargetFile' );
if ~isModelReference && ( isequal( simMode, 'rapid-accelerator' ) ) &&  ...
isequal( simStatus, 'initializing' )
error( message( 'soc:scheduler:SimModeNotSupported' ) );
end 
if ~isModelReference && isequal( simMode, 'accelerator' ) &&  ...
~isequal( simStatus, 'updating' ) && isequal( stfFile, 'ert.tlc' )
error( message( 'soc:scheduler:RTWBuildWithAccelMode' ) );
end 
end 


function checkTaskManagerSemantics( modelName, isModelReference )
import soc.internal.connectivity.*
if isModelReference
taskMgr = getTaskManagerBlock( modelName, 'overrideAssert' );
if ~isempty( taskMgr )
error( message( 'soc:scheduler:TaskMgrMisplaced' ) );
end 
end 
end 


function synchronizeScheduleEditorSchedule( hMdl )
if contains( get_param( hMdl, 'Solver' ), 'Variable' ), return ;end 
rtwSet = get_param( hMdl, 'RTWGenSettings' );
if isempty( rtwSet ), return ;end 
scheduleFile = [ fullfile( pwd, rtwSet.RelativeBuildDir, hMdl ), 'Schedule.mat' ];
rebuild = true;
if exist( scheduleFile, 'file' )
savedSchedule = load( scheduleFile );
mgrBlk = soc.internal.connectivity.getTaskManagerBlock( hMdl, true );
if isempty( mgrBlk ) || ( iscell( mgrBlk ) && numel( mgrBlk ) > 1 ), return ;end 
mdlBlk = soc.internal.connectivity.getModelConnectedToTaskManager( mgrBlk );
refMdl = get_param( mdlBlk, 'ModelName' );
refSchedule = get_param( refMdl, 'Schedule' );
if isfield( savedSchedule, 'refSchedule' ) &&  ...
isequal( refSchedule, savedSchedule.refSchedule )
rebuild = false;
end 
end 
if rebuild
curCD = get_param( hMdl, 'CoderTargetData' );
thisVal = curCD.ESB.ScheduleEditorScheduleReset;
curCD.ESB.ScheduleEditorScheduleReset = ~( thisVal );
set_param( hMdl, 'CoderTargetData', curCD );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpYH5U1S.p.
% Please follow local copyright laws when handling this file.

