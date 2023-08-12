function varargout = pil_target_sim( hModel, pil_target_sim_isMenuSim, varargin )














pil_target_sim_model = get_param( hModel, 'Name' );
clear( 'hModel' );

hiddenModelDescription = coder.connectivity.TopModelSILPIL.TopModelXILHarnessDescripton;

simMode = get_param( pil_target_sim_model, 'SimulationMode' );
assert( any( strcmp( { 'processor-in-the-loop (pil)',  ...
'software-in-the-loop (sil)' },  ...
simMode ) ), 'Simulation mode must be SIL or PIL' );


pil_target_sim_pilBlkModel = i_temp_model_name( pil_target_sim_model, hiddenModelDescription );
coder.connectivity.SimulinkInterface.createModelFromOriginal( pil_target_sim_model,  ...
pil_target_sim_pilBlkModel );

coder.connectivity.TopModelSILPIL.updateWrapperModelMap( pil_target_sim_model, pil_target_sim_pilBlkModel );
pil_target_sim_cleanupWrapperModelMap =  ...
onCleanup( @(  )coder.connectivity.TopModelSILPIL.updateWrapperModelMap( pil_target_sim_model, '' ) );








set_param( pil_target_sim_pilBlkModel, 'SaveState', 'off' );
set_param( pil_target_sim_pilBlkModel, 'SaveFinalState', 'off' );



if strncmp( get_param( pil_target_sim_pilBlkModel, 'SignalResolutionControl' ), 'TryResolve', 10 )
set_param( pil_target_sim_pilBlkModel, 'SignalResolutionControl', 'UseLocalSettings' );
end 



set_param( pil_target_sim_pilBlkModel, 'RecordCoverage', 'off' );

isSIL = strcmp( simMode, 'software-in-the-loop (sil)' );
if slfeature( 'XilNoWrapper' )

block = [  ];

buildDirInfo = RTW.getBuildDir( pil_target_sim_model );





lDefaultCompInfo = coder.internal.DefaultCompInfo.createDefaultCompInfo;
lXilCompInfo = i_getXilCompInfo( getActiveConfigSet( pil_target_sim_model ), isSIL, lDefaultCompInfo );
silPILBlock = pil_block_configure( block,  ...
pil_target_sim_model,  ...
buildDirInfo.CodeGenFolder,  ...
buildDirInfo.BuildDirectory,  ...
isSIL,  ...
lXilCompInfo,  ...
lDefaultCompInfo,  ...
'TopModelPILWrapperModel', pil_target_sim_pilBlkModel );
clear( 'block',  ...
'isSIL',  ...
'buildDirInfo',  ...
'lXilCompInfo',  ...
'lDefaultCompInfo' );
locFunctionXilNoWrapper( silPILBlock, pil_target_sim_model, pil_target_sim_pilBlkModel );
return ;
else 

silPILBlock = locCreateModelBlock( pil_target_sim_model,  ...
isSIL,  ...
pil_target_sim_pilBlkModel );
clear( 'isSIL' );
end 

pilBlkHandle = silPILBlock;
clear( 'silPILBlock' );


pilBlkPosn = get_param( pilBlkHandle, 'Position' );
shiftX = 300;
shiftY = 100;
pilBlkPosn = pilBlkPosn + [ shiftX, shiftY, shiftX, shiftY ];
set_param( pilBlkHandle, 'Position', pilBlkPosn );
clear( 'pilBlkPosn', 'shiftX', 'shiftY' );

pil_target_sim_portInfo = pil_configure_io_ports( pilBlkHandle, pil_target_sim_model );%#ok<NASGU>
clear( 'pilBlkHandle' );


if pil_target_sim_isMenuSim

narginchk( 2, 2 );
nargoutchk( 0, 0 );

pil_target_sim_targetWS = 'base';
pil_target_sim_simOpts = [  ];
else 

narginchk( 6, 6 );
pil_target_sim_timeSpan = varargin{ 1 };
simOptsOrig = varargin{ 2 };
pil_target_sim_extInputs = varargin{ 3 };
returnDstWkspOutput = varargin{ 4 };


pil_target_sim_captureErrors = false;
if isfield( simOptsOrig, 'CaptureErrors' )
if strcmpi( simOptsOrig.CaptureErrors, 'on' )
pil_target_sim_captureErrors = true;

simOptsOrig.ReturnWorkspaceOutputs = 'on';
end 
end 















pil_target_sim_simOpts = simset(  );

fieldNames = fieldnames( simOptsOrig );
for i = 1:length( fieldNames )
pil_target_sim_simOpts.( fieldNames{ i } ) = simOptsOrig.( fieldNames{ i } );
end 















if returnDstWkspOutput
pil_target_sim_simOpts.ReturnWorkspaceOutputs = 'on';
end 
clear( 'fieldNames', 'i', 'simOptsOrig', 'returnDstWkspOutput' );

if isempty( pil_target_sim_simOpts.DstWorkspace )

pil_target_sim_targetWS = 'caller';
else 
switch pil_target_sim_simOpts.DstWorkspace
case 'base'
pil_target_sim_targetWS = 'base';
case 'current'

pil_target_sim_targetWS = 'caller';
otherwise 
assert( false, 'Unsupported workspace: %s', pil_target_sim_simOpts.DstWorkspace );
end 
end 
end 

pil_target_sim_returnWkspaceOutputs =  ...
i_isOptionOn( pil_target_sim_model, pil_target_sim_simOpts, 'ReturnWorkspaceOutputs' );














set_param( pil_target_sim_pilBlkModel, 'InspectSignalLogs', 'off' );

pil_target_sim_SDIRuns = length( Simulink.sdi.Instance.engine.getAllRunIDs );


x_offset = 1100;y_offset = 10;
wrapperModelNote = sprintf( [  ...
'WRAPPER MODEL FOR PIL SIMULATION\n' ...
, 'This model is normally only visible if an error has occurred.\n' ...
, 'Once you have investigated the error, you should close this model\n' ...
, 'without saving. Do not make any changes to this model: it may be\n' ...
, 'deleted without warning.' ] );
add_block( 'built-in/Note', [ pil_target_sim_pilBlkModel, '/', wrapperModelNote ],  ...
'Position', [ 0, 0, x_offset, y_offset ] );
clear( 'wrapperModelNote', 'x_offset', 'y_offset' );


set_param( pil_target_sim_pilBlkModel, 'Description', hiddenModelDescription );
clear( 'hiddenModelDescription' );

if strcmp( simMode, 'software-in-the-loop (sil)' )
simModeStr = 'SIL';
else 
simModeStr = 'PIL';
end 
statusMsg = DAStudio.message( 'Simulink:tools:pilRunning', simModeStr );
pil_target_sim_buildInProgress = Simulink.BuildInProgress( pil_target_sim_model );
set_param( pil_target_sim_model, 'StatusString', statusMsg );
clear( 'statusMsg', 'simModeStr', 'simMode' );


pil_target_sim_cleanupStatus =  ...
onCleanup( @(  )cleanupOriginalModelStatus( pil_target_sim_model, pil_target_sim_buildInProgress ) );
clear pil_target_sim_buildInProgress;


if ~pil_target_sim_returnWkspaceOutputs
if i_isOptionOn( pil_target_sim_model, pil_target_sim_simOpts, 'SignalLogging' )
logName = i_getOption( pil_target_sim_model, pil_target_sim_simOpts, 'SignalLoggingName' );
evalin( pil_target_sim_targetWS, [ logName, '=[];' ] );
clear( 'logName' );
end 
end 


pil_target_sim_simMetadataWrapper_model = Simulink.SimMetadataWrapper( pil_target_sim_model );


set_param( pil_target_sim_pilBlkModel, 'Dirty', 'off' );



if pil_target_sim_isMenuSim



processor_callback = coder.connectivity.XilSimModelNameCorrector( pil_target_sim_pilBlkModel, pil_target_sim_model );


model_name_processor = Simulink.output.registerProcessor( processor_callback, 'Event', 'ALL' );%#ok<NASGU>


pil_target_sim_simMetadataWrapper_model.enterExecutionPhase(  );

set_param( pil_target_sim_pilBlkModel, 'SimulationCommand', 'Start' );

while ~strcmp( 'stopped', get_param( pil_target_sim_pilBlkModel, 'SimulationStatus' ) )
pause( 0.1 );
end 


isOpenNagForModel = processor_callback.haserrors(  );


clear processor_callback;
clear model_name_processor;

if isOpenNagForModel

open_system( pil_target_sim_pilBlkModel );
return ;
end 
if pil_target_sim_returnWkspaceOutputs

returnWkspaceVarName = i_getOption( pil_target_sim_model, pil_target_sim_simOpts, 'ReturnWorkspaceOutputsName' );
pil_target_sim_SimOut = evalin( pil_target_sim_targetWS, returnWkspaceVarName );
else 
pil_target_sim_SimOut = [  ];
end 
else 

try 






pil_target_sim_noneSimVars = {  };
if nargout > 0
pil_target_sim_noneSimVars{ end  + 1 } = 'varargout';
end 
pil_target_sim_noneSimVars{ end  + 1 } = 'pil_target_sim_SimOut';
pil_target_sim_noneSimVars = [ pil_target_sim_noneSimVars, who' ];




i_checkPreSimWorkspaceForPrefix( pil_target_sim_noneSimVars );


pil_target_sim_simMetadataWrapper_model.enterExecutionPhase(  );


bdAssociatedDataId = 'SL_SimInputForSILPIL';
modelHandle = get_param( pil_target_sim_model, 'Handle' );
if Simulink.BlockDiagramAssociatedData.isRegistered( modelHandle, bdAssociatedDataId ) &&  ...
~isempty( Simulink.BlockDiagramAssociatedData.get( modelHandle, bdAssociatedDataId ) )
simInput = Simulink.BlockDiagramAssociatedData.get( modelHandle, bdAssociatedDataId );

simInput.ModelName = pil_target_sim_pilBlkModel;
simInput = simInput.setModelParameter( "SimulationMode", "normal" );




simInput.BlockParameters = [  ];

pil_target_sim_SimOut = sim( simInput );
clear( 'simInput' );
elseif pil_target_sim_returnWkspaceOutputs
pil_target_sim_SimOut = sim( pil_target_sim_pilBlkModel,  ...
pil_target_sim_timeSpan,  ...
pil_target_sim_simOpts,  ...
pil_target_sim_extInputs );
else 
pil_target_sim_SimOut = [  ];

if ( nargout == 0 )
sim( pil_target_sim_pilBlkModel, pil_target_sim_timeSpan, pil_target_sim_simOpts, pil_target_sim_extInputs );
else 
[ varargout{ 1:nargout } ] = sim( pil_target_sim_pilBlkModel, pil_target_sim_timeSpan,  ...
pil_target_sim_simOpts, pil_target_sim_extInputs );
end 
end 
clear( 'modelHandle', 'bdAssociatedDataId' );




pil_target_sim_varsSim = setdiff( who, pil_target_sim_noneSimVars );
catch eObj
if pil_target_sim_captureErrors


pil_target_sim_SimOut = locCreateSimulationOutput( eObj, pil_target_sim_model );
varargout{ 1 } = pil_target_sim_SimOut;

bdclose( pil_target_sim_pilBlkModel );

return ;
else 

open_system( pil_target_sim_pilBlkModel );
rethrow( eObj );
end 
end 
if pil_target_sim_returnWkspaceOutputs
assert( isempty( pil_target_sim_varsSim ),  ...
'pil_target_sim_varsSim should be empty.' );
else 

for pil_target_sim_idx = 1:length( pil_target_sim_varsSim )
assignin( pil_target_sim_targetWS,  ...
pil_target_sim_varsSim{ pil_target_sim_idx },  ...
eval( pil_target_sim_varsSim{ pil_target_sim_idx } ) );
end 
end 
end 




isSignalLoggingOn = i_isOptionOn( pil_target_sim_model, pil_target_sim_simOpts, 'SignalLogging' );
if isSignalLoggingOn
pil_target_sim_logsOutName = i_getOption( pil_target_sim_model,  ...
pil_target_sim_simOpts,  ...
'SignalLoggingName' );
if pil_target_sim_returnWkspaceOutputs

pil_target_sim_logsOutVar = locRetrieveVarIfExists( pil_target_sim_SimOut, pil_target_sim_logsOutName );
else 

pil_target_sim_logsOutVar = evalin( pil_target_sim_targetWS, pil_target_sim_logsOutName );
end 
end 

if ~isSignalLoggingOn

pil_target_sim_logsOutVar = [  ];
pil_target_sim_logsOutName = [  ];
end 


pil_target_sim_updateYout = i_needToUpdateYout( pil_target_sim_model,  ...
pil_target_sim_simOpts,  ...
pil_target_sim_isMenuSim,  ...
pil_target_sim_returnWkspaceOutputs );



if pil_target_sim_updateYout
saveOutputNameCommaDelim = i_getOption( pil_target_sim_model,  ...
pil_target_sim_simOpts,  ...
'OutputSaveName' );

saveOutputNameCell = textscan( saveOutputNameCommaDelim, '%s', 'delimiter', ',' );
pil_target_sim_saveOutputNames = strtrim( saveOutputNameCell{ 1 } );
pil_target_sim_saveOutputVars = cell( 1, length( pil_target_sim_saveOutputNames ) );

if pil_target_sim_returnWkspaceOutputs
for saveNameIdx = 1:length( pil_target_sim_saveOutputNames )

pil_target_sim_saveOutputVars{ saveNameIdx } = locRetrieveVarIfExists( pil_target_sim_SimOut, pil_target_sim_saveOutputNames{ saveNameIdx } );
end 
else 
assert( pil_target_sim_isMenuSim,  ...
'Only menu sim supported for non-single output format.' );
for saveNameIdx = 1:length( pil_target_sim_saveOutputNames )

if evalin( pil_target_sim_targetWS,  ...
[ 'exist(''', pil_target_sim_saveOutputNames{ saveNameIdx }, ''', ''var'')' ] )
pil_target_sim_saveOutputVars{ saveNameIdx } = evalin( pil_target_sim_targetWS, pil_target_sim_saveOutputNames{ saveNameIdx } );
else 

pil_target_sim_saveOutputVars{ saveNameIdx } = [  ];
end 
end 
end 

pil_target_sim_saveOutputVars = i_updateSaveOutputVars( pil_target_sim_saveOutputVars,  ...
pil_target_sim_pilBlkModel,  ...
pil_target_sim_model );
else 
pil_target_sim_saveOutputVars = [  ];
pil_target_sim_saveOutputNames = [  ];
end 

isSaveStateOn = i_isOptionOn( pil_target_sim_model, pil_target_sim_simOpts, 'SaveState' );
if isSaveStateOn &&  ...
coder.internal.connectivity.featureOn( 'UseMF0CodeDescriptorStateLogging' ) &&  ...
strcmp( get_param( pil_target_sim_model, 'SaveFormat' ), 'Dataset' )
pil_target_sim_saveStateNames = i_getOption( pil_target_sim_model, pil_target_sim_simOpts, 'StateSaveName' );
vvv = {  };
vvv{ 1 } = pil_target_sim_saveStateNames;
vvv{ 2 } = double.empty( 1, 0 );
vvv{ 3 } = '';
vvv{ 4 } = 'state';
vvv{ 5 } = struct.empty;
pil_target_sim_saveStateVars =  ...
Simulink.sdi.internal.getStreamedRunDataForModel( pil_target_sim_model, vvv{ : } );
if pil_target_sim_returnWkspaceOutputs
eval( [ 'pil_target_sim_SimOut.', pil_target_sim_saveStateNames, ' = [];' ] );
end 
else 
pil_target_sim_saveStateNames = [  ];
pil_target_sim_saveStateVars = [  ];
end 


if pil_target_sim_returnWkspaceOutputs

pil_target_sim_SimOut = i_updateReturnWkspaceVar( pil_target_sim_SimOut,  ...
pil_target_sim_logsOutVar,  ...
pil_target_sim_logsOutName,  ...
pil_target_sim_saveOutputVars,  ...
pil_target_sim_saveOutputNames,  ...
pil_target_sim_saveStateNames,  ...
pil_target_sim_saveStateVars,  ...
pil_target_sim_simMetadataWrapper_model );
if pil_target_sim_isMenuSim

assignin( pil_target_sim_targetWS,  ...
returnWkspaceVarName,  ...
pil_target_sim_SimOut );
else 

if nargout == 0
assignin( pil_target_sim_targetWS,  ...
'ans',  ...
pil_target_sim_SimOut );
else 
assert( nargout == 1,  ...
'nargout must be 0 or 1 for SimOut' );
varargout{ 1 } = pil_target_sim_SimOut;
end 
end 
else 

if ~isempty( pil_target_sim_logsOutVar )
assignin( pil_target_sim_targetWS,  ...
pil_target_sim_logsOutName,  ...
pil_target_sim_logsOutVar );
end 

if ~isempty( pil_target_sim_saveOutputVars )
for saveOutputVarIdx = 1:length( pil_target_sim_saveOutputVars )
assignin( pil_target_sim_targetWS,  ...
pil_target_sim_saveOutputNames{ saveOutputVarIdx },  ...
pil_target_sim_saveOutputVars{ saveOutputVarIdx } );
end 
end 

if isSaveStateOn
if ~isempty( pil_target_sim_saveStateNames )
assignin( pil_target_sim_targetWS, pil_target_sim_saveStateNames,  ...
pil_target_sim_saveStateVars );
elseif nargout < 2
stateName = i_getOption( pil_target_sim_model, pil_target_sim_simOpts, 'StateSaveName' );
evalin( pil_target_sim_targetWS, [ stateName, '= [];' ] );
end 
end 

if i_isOptionOn( pil_target_sim_model, pil_target_sim_simOpts, 'SaveFinalState' )
finalName = i_getOption( pil_target_sim_model, pil_target_sim_simOpts, 'FinalStateName' );
evalin( pil_target_sim_targetWS, [ finalName, '= [];' ] );
end 

if i_isOptionOn( pil_target_sim_model, pil_target_sim_simOpts, 'DSMLogging' )
dsmName = i_getOption( pil_target_sim_model, pil_target_sim_simOpts, 'DSMLoggingName' );
evalin( pil_target_sim_targetWS, [ dsmName, '= [];' ] );
end 
end 

if i_isOptionOn( pil_target_sim_model, pil_target_sim_simOpts, 'SaveOutput' ) &&  ...
~strcmpi( i_getOption( pil_target_sim_model, pil_target_sim_simOpts, 'SaveFormat' ), 'dataset' )





sde = Simulink.sdi.Instance.engine;
stepping = 0;
if pil_target_sim_isMenuSim

loggingMetaData = i_getOption( pil_target_sim_model,  ...
pil_target_sim_simOpts,  ...
'TopModelXILLoggingMetaData' );
end 

loggingMetaData.isTopModelXIL = true;





sde.createRunFromModel( pil_target_sim_model, loggingMetaData, stepping );
clear( 'loggingMetaData' );
end 


i_updateMetaDataInSDI( pil_target_sim_model, pil_target_sim_simMetadataWrapper_model );

runs = length( Simulink.sdi.Instance.engine.getAllRunIDs );
if pil_target_sim_SDIRuns < runs
Simulink.sdi.internal.SLMenus.getSetNewDataAvailable( pil_target_sim_model, true );
end 


close_system( pil_target_sim_pilBlkModel, 0 );



function i_updateMetaDataInSDI( model, metaDataWrapper )
storedRun = Simulink.sdi.getCurrentSimulationRun( model, '', false );
if ~isempty( storedRun )
metaData = metaDataWrapper.matlabStruct;

assert( isfield( metaData, 'TimingInfo' ), 'No TimingInfo in metadata' );

modelUpdateTime = metaData.TimingInfo.InitializationElapsedWallTime;
modelSimTime = metaData.TimingInfo.ExecutionElapsedWallTime;
modelTermTime = metaData.TimingInfo.TerminationElapsedWallTime;
modelTotalTime = metaData.TimingInfo.TotalElapsedWallTime;

[ stopTime, status ] = str2num( get_param( model, 'StopTime' ) );
if ~status
stopTime = 0;
end 

DatasetSignalFormat = 0;
if bdIsLoaded( metaData.ModelInfo.ModelName )
if isequal( get_param( metaData.ModelInfo.ModelName, 'DatasetSignalFormat' ), 'timetable' )
DatasetSignalFormat = 1;
end 
end 

solverType = get_param( model, 'SolverType' );
if strcmpi( solverType, 'Fixed-step' )
stepSize = get_param( model, 'FixedStep' );
else 
stepSize = get_param( model, 'MaxStep' );
end 

stopEventSource = '';
if ~isempty( metaData.ExecutionInfo.StopEventSource )

len = metaData.ExecutionInfo.StopEventSource.getLength(  );
if len
stopEventSource = metaData.ExecutionInfo.StopEventSource.getBlock( len );
end 
end 

execErrors = locGetDiagString( metaData.ExecutionInfo.ErrorDiagnostic );
execWarnings = locGetDiagString( metaData.ExecutionInfo.WarningDiagnostics );

slVersionStr = sprintf( '%s %s %s',  ...
metaData.ModelInfo.SimulinkVersion.Name,  ...
metaData.ModelInfo.SimulinkVersion.Version,  ...
metaData.ModelInfo.SimulinkVersion.Release );
Simulink.HMI.updateRunMetaData( storedRun.id,  ...
metaData.ModelInfo.ModelName,  ...
metaData.ModelInfo.SimulationMode,  ...
metaData.ModelInfo.StartTime,  ...
stopTime,  ...
metaData.ModelInfo.ModelVersion,  ...
metaData.ModelInfo.UserID,  ...
metaData.ModelInfo.MachineName,  ...
locCapitalizeFirstLetter( solverType ),  ...
get_param( model, 'Solver' ),  ...
slVersionStr,  ...
modelUpdateTime,  ...
modelSimTime,  ...
modelTermTime,  ...
modelTotalTime,  ...
DatasetSignalFormat,  ...
metaData.ModelInfo.Platform,  ...
stepSize,  ...
metaData.ExecutionInfo.StopEvent,  ...
stopEventSource,  ...
metaData.ExecutionInfo.StopEventDescription,  ...
execErrors,  ...
execWarnings,  ...
metaData.UserString );
Simulink.sdi.internal.flushStreamingBackend(  );
end 


function ret = locGetDiagString( diags )
ret = '';
for idx = 1:numel( diags )
if isempty( ret )
ret = diags( idx ).Diagnostic.message;
else 
ret = sprintf( '%s\n%s', ret, diags( idx ).Diagnostic.message );
end 
end 




function updateYout = i_needToUpdateYout( pil_target_sim_model,  ...
pil_target_sim_simOpts,  ...
pil_target_sim_isMenuSim,  ...
pil_target_sim_returnWkspaceOutputs )


if i_isOptionOn( pil_target_sim_model, pil_target_sim_simOpts, 'SaveOutput' ) &&  ...
~strcmpi( i_getOption( pil_target_sim_model, pil_target_sim_simOpts, 'SaveFormat' ), 'dataset' ) &&  ...
( pil_target_sim_isMenuSim || pil_target_sim_returnWkspaceOutputs )
updateYout = true;
else 
updateYout = false;
end 


function saveOutputVars = i_updateSaveOutputVars( saveOutputVars,  ...
pil_target_sim_pilBlkModel,  ...
pil_target_sim_model )
for saveOutputVarIdx = 1:length( saveOutputVars )
if isstruct( saveOutputVars{ saveOutputVarIdx } )
if isfield( saveOutputVars{ saveOutputVarIdx }, 'signals' )
for sigIdx = 1:length( saveOutputVars{ saveOutputVarIdx }.signals )
if isstruct( saveOutputVars{ saveOutputVarIdx }.signals( sigIdx ) )
if isfield( saveOutputVars{ saveOutputVarIdx }.signals( sigIdx ), 'blockName' )
saveOutputVars{ saveOutputVarIdx }.signals( sigIdx ).blockName =  ...
strrep( saveOutputVars{ saveOutputVarIdx }.signals( sigIdx ).blockName,  ...
pil_target_sim_pilBlkModel,  ...
pil_target_sim_model );
end 
end 
end 
end 
end 
end 


function returnWkspaceVar = i_updateReturnWkspaceVar( returnWkspaceVar,  ...
logsOutVar,  ...
logsOutName,  ...
saveOutputVars,  ...
saveOutputNames,  ...
saveStateName,  ...
saveStateVar,  ...
pil_target_sim_simMetadataWrapper_model )

elNames = returnWkspaceVar.getElementNames;
pilBlkModel_metadata = returnWkspaceVar.getSimulationMetadata(  );
if ~isempty( elNames )
for elIdx = 1:length( elNames )
elName = elNames{ elIdx };
elValue = returnWkspaceVar.get( elName );
if strcmp( elName, logsOutName )

elValue = logsOutVar;
elseif strcmp( elName, saveStateName )

elValue = saveStateVar;
else 

saveOutputIdx = find( strcmp( elName, saveOutputNames ), 1 );
if ~isempty( saveOutputIdx )

elValue = saveOutputVars{ saveOutputIdx };
end 
end 

newData.( elName ) = elValue;
end 
returnWkspaceVar = Simulink.SimulationOutput( newData,  ...
i_getCombinedMetadata( pil_target_sim_simMetadataWrapper_model,  ...
pilBlkModel_metadata ) );
else 
returnWkspaceVar = Simulink.SimulationOutput( struct(  ),  ...
i_getCombinedMetadata( pil_target_sim_simMetadataWrapper_model,  ...
pilBlkModel_metadata ) );
end 


function i_checkPreSimWorkspaceForPrefix( vars )


prefix = [ mfilename, '_' ];
for i = 1:length( vars )
var = vars{ i };

if strcmp( var, 'varargin' ) || strcmp( var, 'varargout' )
continue ;
end 
index = strfind( var, prefix );
assert( ~isempty( index ) && ( index == 1 ),  ...
'Variable name "%s" does not have required prefix "%s"',  ...
var,  ...
prefix );
end 



function optionValue = i_getOption( model, options, optionName )

if ~isempty( options ) &&  ...
isfield( options, optionName ) &&  ...
~isempty( options.( optionName ) )

optionValue = options.( optionName );
else 

optionValue = get_param( model, optionName );
end 


function isOn = i_isOptionOn( model, options, optionName )
optionValue = i_getOption( model, options, optionName );
switch optionValue
case 'on'
isOn = true;
case 'off'
isOn = false;
otherwise 
assert( false, 'Unexpected value for option: %s', optionName );
end 


function modelName = i_temp_model_name( model, hiddenModelDescription )

bigUpperLimit = 10000;
base_suffix = '_wrapper';
suffix = base_suffix;

for i = 1:bigUpperLimit

modelName = [ model( 1:min( end , ( namelengthmax - length( suffix ) ) ) ), suffix ];


if isempty( find_system( 'type', 'block_diagram', 'name', modelName ) )
break ;
else 
description = get_param( modelName, 'Description' );
if true == strcmp( description, hiddenModelDescription )

close_system( modelName, 0, 'CloseReferencedModels', false );

break ;
else 
suffix = [ '_wrapper', num2str( i ) ];
end 
end 
end 

assert( i < bigUpperLimit, 'Could not identify a name for the wrapper model.' );

function locFunctionXilNoWrapper( silPILBlock, pil_target_sim_model, pil_target_sim_pilBlkModel )
blkH = silPILBlock.getParam( 'handle' );


rtw.pil.SILPILBlock.SILBlockInitialization( blkH )


interface = rtw.pil.SILPILBlock.getPILData( blkH );


inTheLoopType = rtw.pil.InTheLoopType.Block;
handler = coder.connectivity.PILDataHandler.createHandler( inTheLoopType );
handler.setPILData( pil_target_sim_model, interface );


close_system( pil_target_sim_pilBlkModel, 0 );
clear( 'blkH' );
return ;



function struct_model = i_getCombinedMetadata( m_model, pilBlkModel_metadata )

struct_model = m_model.matlabStruct(  );
struct_model.TimingInfo.WallClockTimestampStop =  ...
pilBlkModel_metadata.TimingInfo.WallClockTimestampStop;
struct_model.TimingInfo.InitializationElapsedWallTime =  ...
pilBlkModel_metadata.TimingInfo.InitializationElapsedWallTime +  ...
struct_model.TimingInfo.InitializationElapsedWallTime;
struct_model.TimingInfo.ExecutionElapsedWallTime =  ...
pilBlkModel_metadata.TimingInfo.ExecutionElapsedWallTime;
struct_model.TimingInfo.TerminationElapsedWallTime =  ...
pilBlkModel_metadata.TimingInfo.TerminationElapsedWallTime;
struct_model.TimingInfo.TotalElapsedWallTime =  ...
struct_model.TimingInfo.InitializationElapsedWallTime +  ...
struct_model.TimingInfo.ExecutionElapsedWallTime +  ...
struct_model.TimingInfo.TerminationElapsedWallTime;
struct_model.ModelInfo.StopTime = pilBlkModel_metadata.ModelInfo.StopTime;
struct_model.ModelInfo.SolverInfo =  ...
pilBlkModel_metadata.ModelInfo.SolverInfo;
struct_model.ExecutionInfo.WarningDiagnostics =  ...
[ struct_model.ExecutionInfo.WarningDiagnostics; ...
pilBlkModel_metadata.ExecutionInfo.WarningDiagnostics ];
struct_model.ExecutionInfo.ErrorDiagnostic =  ...
[ struct_model.ExecutionInfo.ErrorDiagnostic; ...
pilBlkModel_metadata.ExecutionInfo.ErrorDiagnostic ];
struct_model.ExecutionInfo.StopEvent =  ...
pilBlkModel_metadata.ExecutionInfo.StopEvent;
struct_model.ExecutionInfo.StopEventSource =  ...
pilBlkModel_metadata.ExecutionInfo.StopEventSource;
struct_model.ExecutionInfo.StopEventDescription =  ...
pilBlkModel_metadata.ExecutionInfo.StopEventDescription;




function out = locCreateSimulationOutput( ME, modelName )
metadataWrapper = Simulink.SimMetadataWrapper( modelName );
metaStruct = metadataWrapper.matlabStruct( 1 );
metaStruct.ExecutionInfo.StopEvent = 'DiagnosticError';
metaStruct.ExecutionInfo.StopEventDescription = ME.message;
metaStruct.ExecutionInfo.ErrorDiagnostic =  ...
struct( 'Diagnostic', MSLDiagnostic( ME ) );
out = Simulink.SimulationOutput( struct, metaStruct );


function lXilCompInfo = i_getXilCompInfo( cs, isSIL, lDefaultCompInfo )

lIsSilAndPws = isSIL && strcmp( get_param( cs, 'PortableWordSizes' ), 'on' );

lXilCompInfo = coder.internal.utils.XilCompInfo ...
.slCreateXilCompInfo( cs, lDefaultCompInfo, lIsSilAndPws );


function outVar = locRetrieveVarIfExists( simout, varname )



outVar = [  ];
allVars = simout.who;
if ( any( strcmp( allVars, varname ) ) )
outVar = simout.get( varname );
end 


function modelBlock = locCreateModelBlock( modelName,  ...
isSILMode,  ...
harnessModel )

if isSILMode
simulationMode = 'Software-in-the-Loop (SIL)';
targetBlockName = 'SIL Block';
else 
simulationMode = 'Processor-in-the-Loop (PIL)';
targetBlockName = 'PIL Block';
end 

h = get_param( harnessModel, 'Handle' );


libBlock = 'simulink/Ports & Subsystems/Model';


modelBlock = add_block( libBlock,  ...
[ get_param( h, 'Name' ), '/', targetBlockName ],  ...
'Position', [ 15, 15, 100, 70 ] );

set_param( modelBlock, 'ModelName', modelName );
set_param( modelBlock, 'SimulationMode', simulationMode );
set_param( modelBlock, 'CodeInterface', 'Top model' );



defaultValueAvailable = slfeature( 'ModelArgumentDefaultVal' ) > 0;
getModelBlockArguments = @( modelBlock )get_param( modelBlock, 'InstanceParameters' );
instParams = getModelBlockArguments( modelBlock );
for i = 1:length( instParams )
paramPath = instParams( i ).Path;
paramName = instParams( i ).Name;
if isempty( paramPath ) || ( paramPath.getLength == 0 )


paramValue = paramName;
else 






paramPathCell = paramPath.convertToCell;

paramPathCell( 1 ) = [  ];

origParamPath = Simulink.BlockPath( paramPathCell );

instParamsOrig = getModelBlockArguments( paramPath.getBlock( 1 ) );

paramValue = [  ];
for j = 1:length( instParamsOrig )
currPath = instParamsOrig( j ).Path;
if strcmp( instParamsOrig( j ).Name, paramName ) &&  ...
( isequal( currPath, origParamPath ) ||  ...
( isempty( currPath ) && origParamPath.getLength == 0 ) )


paramValue = instParamsOrig( j ).Value;
break ;
end 
end 
assert( ~isempty( paramValue ) || defaultValueAvailable,  ...
'Failed to find a paramValue!' );
end 
instParams( i ).Value = paramValue;
end 

set_param( modelBlock, 'InstanceParameters', instParams );

function cleanupOriginalModelStatus( model, buildInProgress )

delete( buildInProgress );
set_param( model, 'StatusString', '' );



function outStr = locCapitalizeFirstLetter( inStr )

expression = '(^|\.|-)\s*.';
replace = '${upper($0)}';
outStr = regexprep( inStr, expression, replace );





% Decoded using De-pcode utility v1.2 from file /tmp/tmpPG63Zp.p.
% Please follow local copyright laws when handling this file.

