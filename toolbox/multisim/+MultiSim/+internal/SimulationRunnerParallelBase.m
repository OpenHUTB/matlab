





classdef ( Abstract )SimulationRunnerParallelBase < MultiSim.internal.SimulationRunner
properties ( Transient = true )
Pool
RunningFevalOnAllFuture = parallel.FevalOnAllFuture.empty
Futures = Simulink.Simulation.Future.empty
FevalFutures = parallel.FevalFuture.empty
end 

properties ( Transient = true, Access = protected )
ToggleCallbacksValue
FutureCompletedListener
FutureIdToRunIdMap
SimulationOutputAvailableListeners = event.listener.empty;
SimulationAbortedListeners = event.listener.empty;
NumWorkers
NumRunsToDispatch
RunsCompletedSinceLastDispatch
AdditionalDispatchSize
FinalJobDiagnostic MSLDiagnostic = MSLDiagnostic.empty
end 

properties ( SetAccess = protected )
SingleSimOutputType = Simulink.Simulation.Future
end 

properties ( Constant, Access = protected )
WorkerCacheFolder = 'slprj'
end 

properties ( Constant, Access = private )
DefaultConfig = MultiSim.internal.SimulationRunnerParallelBaseConfig
end 

properties ( SetAccess = protected, Hidden = true )
MultiSimRunningMessage = message( 'Simulink:Commands:MultiSimRunningSim' )
end 

methods ( Abstract )
arg = createExecutionArgs( obj, fh, simInput )
addDataToSimFuture( obj, simFuture, simInput )
execFh = executeFcnHandle( obj )
end 

methods 

function obj = SimulationRunnerParallelBase( simMgr, pool, namedargs )
R36
simMgr( 1, 1 )Simulink.SimulationManager
pool( 1, 1 )parallel.Pool = gcp
namedargs.Config( 1, 1 )MultiSim.internal.SimulationRunnerParallelBaseConfig = MultiSim.internal.SimulationRunnerParallelBase.DefaultConfig
end 

namedargsCell = namedargs2cell( namedargs );
obj = obj@MultiSim.internal.SimulationRunner( simMgr, namedargsCell{ : } );
load_system( obj.ModelName );
obj.Pool = pool;
if isempty( obj.Pool )

error( message( 'Simulink:Commands:MultiSimNoParPool' ) );
end 
obj.NumWorkers = obj.Pool.NumWorkers;
obj.NumRunsToDispatch = obj.NumSims;
obj.RunsCompletedSinceLastDispatch = 0;
obj.AdditionalDispatchSize = obj.NumWorkers;
end 

function delete( obj )
delete( obj.FutureIdToRunIdMap );
delete( obj.SimulationOutputAvailableListeners );
delete( obj.SimulationAbortedListeners );
delete( obj.FutureCompletedListener );
end 

function simFutures = executeImpl( obj, fh, simIns )
obj.NumSims = numel( simIns );
obj.setupSims( simIns );

obj.Futures = Simulink.Simulation.Future.empty(  );
obj.Futures( obj.NumSims ) = Simulink.Simulation.Future;
obj.FutureIdToRunIdMap = containers.Map( 'KeyType', 'double', 'ValueType', 'double' );

if obj.Options.ShowSimulationManager
simFutures =  ...
obj.executeImplSimManager( fh, simIns );
else 
simFutures =  ...
obj.executeImplNonSimManager( fh, simIns );
end 
end 

function dispatchRunsIfNeeded( obj )
if obj.NumRunsToDispatch == 0
return ;
end 
assert( obj.RunsCompletedSinceLastDispatch < obj.AdditionalDispatchSize, 'Runs completed since last dispatch is greater than additional dispatch size' );
obj.RunsCompletedSinceLastDispatch =  ...
obj.RunsCompletedSinceLastDispatch + 1;
if ( obj.RunsCompletedSinceLastDispatch == obj.AdditionalDispatchSize ||  ...
obj.RunsCompletedSinceLastDispatch == obj.NumRunsToDispatch )
startIdx = obj.NumSims - obj.NumRunsToDispatch + 1;
endIdx = startIdx + obj.RunsCompletedSinceLastDispatch - 1;
assert( endIdx <= obj.NumSims, 'Future endIdx > NumSims' );
obj.NumRunsToDispatch =  ...
obj.NumRunsToDispatch - obj.RunsCompletedSinceLastDispatch;
submit( obj.FevalFutures( startIdx:endIdx ), obj.Pool.FevalQueue );
obj.RunsCompletedSinceLastDispatch = 0;
end 
end 

function assignOutputsOnSimManager( obj )
for i = 1:obj.NumSims
fetchOutputs( obj.Futures( i ) );
end 
end 
end 

methods ( Access = protected )
function F = parfevalOnAll( obj, varargin )
F = parfevalOnAll( varargin{ : } );
obj.RunningFevalOnAllFuture = F;
end 

function simInput = setupSimulationInput( obj, simInput )
simInput = simInput.addHiddenModelParameter( 'CaptureErrors', 'on' );





simInput.UsingManager = true;

simInput.IsUsingPCT = true;

simInfo = Simulink.Simulation.internal.SimInfo;
simInfo.UseFastRestart = obj.Options.UseFastRestart;
simInput.SimInfo = simInfo;
end 

function createSimFuture( obj, future, simInput )
runId = simInput.RunId;
simFuture = Simulink.Simulation.Future(  ...
future, simInput.ModelName, runId );
obj.addDataToSimFuture( simFuture, simInput );
obj.Futures( runId ) = simFuture;
obj.FutureIdToRunIdMap( simFuture.ID ) = runId;
obj.SimulationOutputAvailableListeners( end  + 1 ) =  ...
event.listener( simFuture, 'SimulationOutputAvailable',  ...
@obj.handleOutputAvailable );
obj.SimulationAbortedListeners( end  + 1 ) =  ...
event.listener( simFuture, 'SimulationAborted',  ...
@obj.handleSimulationAborted );
end 

function simFutures = executeImplNonSimManager( obj, fh, simIns )
for i = 1:obj.NumSims
arg = obj.createExecutionArgs( fh, simIns( i ) );
future = parfeval( obj.Pool, obj.executeFcnHandle(  ), 1, arg{ : } );
obj.createSimFuture( future, simIns( i ) );
end 

simFutures = obj.Futures;
eventData = MultiSim.internal.SimulationRunnerEventData( simFutures );
notify( obj, 'AllSimulationsQueued', eventData );
end 

function simFutures = executeImplSimManager( obj, fh, simIns )
args = cell( 1, obj.NumSims );
for i = 1:obj.NumSims
args{ i } = obj.createExecutionArgs( fh, simIns( i ) );
end 

futures = parallel.FevalFuture( obj.executeFcnHandle(  ), 1, args );
obj.FevalFutures = futures;

for i = 1:obj.NumSims
obj.createSimFuture( futures( i ), simIns( i ) );
end 

simFutures = obj.Futures;
eventData = MultiSim.internal.SimulationRunnerEventData( simFutures );
notify( obj, 'AllSimulationsQueued', eventData );

initNumSim = min( obj.NumSims,  ...
max(  ...
min( max( 5 * obj.NumWorkers, 100 ), 500 ),  ...
obj.NumWorkers ) );
obj.NumRunsToDispatch = obj.NumRunsToDispatch - initNumSim;
submit( futures( 1:initNumSim ), obj.Pool.FevalQueue );
end 

function setupDataDictionaryCache( obj )






parfevalOnAll( obj.Pool, @bdclose, 0, 'all' );

parfevalOnAll( obj.Pool, @Simulink.data.dictionary.closeAll, 0, '-discard' );

F = parfevalOnAll( obj.Pool, @locSetupWorkerDataDictionaryCache, 0 );
wait( F );


if ~isempty( F.Error )
throw( F.Error{ 1 } );
end 
end 

function simInputs = setupFastRestart( obj, simInputs )
if obj.Options.UseFastRestart
loggedSignalsUnionMap = MultiSim.internal.getUnionOfAllLoggedSignals( simInputs );
sigs = values( loggedSignalsUnionMap );
signalsToLog = [  ];
for idx = 1:numel( sigs )
bPath = sigs{ idx }.BlockPath.convertToCell;
ph = get_param( bPath{ end  }, 'PortHandles' );
ph = ph.Outport( sigs{ idx }.OutputPortIndex );
if strcmp( get_param( ph, 'DataLogging' ), 'off' )
signalsToLog = [ signalsToLog, sigs{ idx } ];%#ok<AGROW>
end 
end 
simInputs = MultiSim.internal.resetLoggingSpec( loggedSignalsUnionMap, simInputs );
parfevalOnAll( obj.Pool, @MultiSim.internal.SimulationRunner.turnOnLoggingForSignals, 0, signalsToLog, obj.ModelName );
end 
end 

function cleanupDataDictionaryCache( obj )

parfevalOnAll( obj.Pool, @bdclose, 0, 'all' );

parfevalOnAll( obj.Pool, @Simulink.data.dictionary.closeAll, 0, '-discard' );

parfevalOnAll( obj.Pool, @Simulink.data.dictionary.cleanupWorkerCache, 0 );
end 

function clearSDIRepositoryFile( ~ )
Simulink.sdi.cleanupWorkerResources(  );
end 

function loadSimulinkOnWorkers( obj )


obj.notifyProgress( message( 'Simulink:MultiSim:LoadingSimulinkWorkers' ) );
F = parfevalOnAll( obj.Pool, @(  )~isempty( ver( 'simulink' ) ), 1 );
isSimulinkAvailable = fetchOutputs( F );
if ~all( isSimulinkAvailable )
error( message( 'Simulink:MultiSim:NoSimulinkOnWorkers' ) );
end 

wait( obj.parfevalOnAll( obj.Pool, @start_simulink, 0 ) );
end 

function loadModelOnWorkers( obj )


obj.notifyProgress( message( 'Simulink:MultiSim:LoadingModelWorkers' ) );
F = obj.parfevalOnAll( obj.Pool, @load_system, 0, obj.ModelName );
wait( F );

if ~isempty( F.Error )

ME = MException( message( 'Simulink:MultiSim:ErrorLoadingModelOnWorkers', obj.ModelName ) );
cause = F.Error( ~cellfun( @isempty, F.Error ) );
ME = ME.addCause( cause{ 1 } );
throw( ME );
end 
end 


function attachSetupFcnDependencies( obj )
if ~isempty( obj.Options.SetupFcn )
fhinfo = functions( obj.Options.SetupFcn );
if ~isempty( fhinfo.file )
parallel.internal.pool.attachDependentFilesToPool( obj.Pool, fhinfo.file );
end 
end 
end 


function attachCleanupFcnDependencies( obj )
if ~isempty( obj.Options.CleanupFcn )
fhinfo = functions( obj.Options.CleanupFcn );
if ~isempty( fhinfo.file )
parallel.internal.pool.attachDependentFilesToPool( obj.Pool, fhinfo.file );
end 
end 
end 


function runSetupFcn( obj )
setupFcn = obj.Options.SetupFcn;

if ~isempty( setupFcn )
obj.notifyProgress( message( 'Simulink:MultiSim:RunGenericParallel', 'SetupFcn' ) );
F = obj.parfevalOnAll( obj.Pool, setupFcn, 0 );
wait( F );


if ~isempty( F.Error )

combinedError = MException( message( 'Simulink:Commands:SetupFcnError' ) );
for i = 1:length( F.Error )
combinedError = combinedError.addCause( F.Error{ i } );
end 
throw( combinedError );
end 
end 
end 


function runCleanupFcn( obj )
cleanupFcn = obj.Options.CleanupFcn;

if ~isempty( cleanupFcn )
obj.notifyProgress( message( 'Simulink:MultiSim:RunGenericParallel', 'CleanupFcn' ) );
F = parfevalOnAll( obj.Pool, cleanupFcn, 0 );
wait( F );





if ~isempty( F.Error )

combinedError = MException( message( 'Simulink:Commands:CleanupFcnError' ) );
for i = 1:length( F.Error )
combinedError = combinedError.addCause( F.Error{ i } );
end 
obj.reportAsWarning( combinedError );
end 
end 
end 

function setupWorkersAndBuild( obj )

obj.doParallelBuild(  );


obj.createSimulationDebugger(  );


obj.setupCacheFolder(  );


obj.runSetupFcn(  );


obj.transferBaseWkspVars(  );


obj.loadModelOnWorkers(  );

obj.reassignBaseWkspVars(  );




obj.setupPackagedModel(  );


parfevalOnAll( obj.Pool, @locCdToCacheFolder, 0 );
end 



function cacheWorkerInitialDirectory( obj )
parfevalOnAll( obj.Pool, @locCacheWorkerInitialDirectory, 0 );
end 

function setupCacheFolder( obj )
obj.notifyProgress( message( 'Simulink:MultiSim:ConfigureSimulinkCache' ) );

parallel.pool.createFolder( obj.Pool, obj.WorkerCacheFolder );





parfevalOnAll( obj.Pool, @locSetupWorkerCacheFolder, 0 );
end 

function setupPackagedModel( obj )

slxcFiles = [  ];
for modelName = obj.AllModels
slxcFiles = [ slxcFiles;MultiSim.internal.getSlxcFilesForModel( modelName ) ];%#ok<AGROW>
end 





if ~isempty( slxcFiles )
wait( parallel.pool.copyToPerHostFolder( obj.Pool, obj.WorkerCacheFolder, slxcFiles' ) );
parfevalOnAll( obj.Pool, @locCopyCacheFilesIntoCacheFolder, 0, obj.WorkerCacheFolder );
end 
end 

function resetCurrentDir( obj )
parfevalOnAll( obj.Pool, @locResetCurrentDir, 0 );
parallel.pool.deleteFolder( obj.Pool, obj.WorkerCacheFolder );
parfevalOnAll( obj.Pool, @locClearWorkerCacheFolder, 0 );
end 

function transferBaseWkspVars( obj )
if obj.Options.TransferBaseWorkspaceVariables
obj.notifyProgress( message( 'Simulink:MultiSim:TransferBaseWkspVars' ) );

varList = evalin( 'base', 'who' );

vars = struct;
for i = 1:numel( varList )
vars.( varList{ i } ) = evalin( 'base', varList{ i } );
end 


obj.parfevalOnAll( obj.Pool, @locCacheAndAssignVars, 0, vars );
end 
end 

function reassignBaseWkspVars( obj )
if obj.Options.TransferBaseWorkspaceVariables
parfevalOnAll( obj.Pool, @locReassignVarsAndClearCache, 0 );
end 
end 

function attachFiles( obj )

warningId = 'parallel:lang:pool:IgnoringAlreadyAttachedFiles';
oldState = warning( 'off', warningId );
oc = onCleanup( @(  )warning( oldState.state, warningId ) );
updateAttachedFiles( obj.Pool );
addAttachedFiles( obj.Pool, obj.Options.AttachedFiles );
end 

function cancelFuture( obj, runId )
obj.CancelRequested = true;
if isempty( obj.Futures )


cancel( obj.RunningFevalOnAllFuture );
obj.notifySimulationAborted( 1:obj.NumSims );
return ;
end 

if isempty( runId )
cancel( obj.Futures )
else 
cancel( obj.Futures( runId ) );
end 
end 

function enableFutureCompletedEvent( obj )
queue = obj.Pool.FevalQueue;



if ~obj.Options.ShowSimulationManager && obj.Options.RunInBackground
obj.ToggleCallbacksValue = queue.hToggleCallbacks( true );
obj.FutureCompletedListener = addlistener(  ...
obj.Pool.FevalQueue, 'FutureCompleted',  ...
@obj.handleFutureCompleted );
else 
obj.ToggleCallbacksValue = queue.hToggleCallbacks( false );
end 
end 

function handleOutputAvailable( obj, ~, eventData )

obj.notify( 'SimulationOutputAvailable', eventData );
simOut = eventData.SimulationOutput;
if isempty( obj.FinalJobDiagnostic )
obj.FinalJobDiagnostic = obj.createDiagnosticForSimulationOutput( simOut );
end 
end 

function handleSimulationAborted( obj, ~, eventData )

obj.notify( 'SimulationAborted', eventData );
end 

function handleFutureCompleted( obj, ~, eventData )
completedFutureId = eventData.FutureID;
if ~isempty( obj.FutureIdToRunIdMap ) && isKey( obj.FutureIdToRunIdMap, completedFutureId )
runId = obj.FutureIdToRunIdMap( completedFutureId );
obj.notifySimulationFinishedRunning( runId );
end 
end 

function projectRoot = getProjectRoot( obj )
projectRoot = MultiSim.internal.projectutils.projectRootForModel( obj.ModelName );
end 

function closeProject( obj )

parfevalOnAll( obj.Pool, @locCloseProject, 0 );
end 

function createSimulationDebugger( obj )
if slfeature( 'ParallelSimulationDebugging' )
obj.SimulationDebugger = MultiSim.internal.SimulationDebuggerParallelClient( obj.ModelName, obj.Pool );
else 
obj.SimulationDebugger = [  ];
end 
end 

function showFinalJobDiagnostic( obj )
if ~isempty( obj.FinalJobDiagnostic )
MultiSim.internal.reportAsWarning( obj.ModelName, obj.FinalJobDiagnostic );
end 
end 
end 

methods ( Access = private )
function diagnostic = createDiagnosticForSimulationOutput( obj, simOut )
diagnostic = MSLDiagnostic.empty;

if ~isempty( simOut.SimulationMetadata )
errorDiagnostic = simOut.SimulationMetadata.ExecutionInfo.ErrorDiagnostic;
if ~isempty( errorDiagnostic )
diagnostic = getAdditionalDiagnosticForError( obj, errorDiagnostic.Diagnostic );
end 
end 
end 

function diagnostic = getAdditionalDiagnosticForError( obj, errorDiagnostic )
diagnostic = MSLDiagnostic.empty;
undefinedVarDiagnostic = errorDiagnostic.findID( "MATLAB:UndefinedFunction" );
if ~isempty( undefinedVarDiagnostic )
undefinedVarDiagnostic = undefinedVarDiagnostic{ 1 };
missingVar = undefinedVarDiagnostic.arguments{ 1 };
varIsInBaseWorkspace = evalin( "base", "exist('" + missingVar + "', 'var')" );
if varIsInBaseWorkspace && ~obj.Options.TransferBaseWorkspaceVariables
diagnostic = MSLDiagnostic( "Simulink:MultiSim:UndefinedVarUseTransferBaseWkspVars", missingVar );
end 
end 
end 
end 
end 

function locCacheAndAssignVars( vars )
instance = MultiSim.internal.WorkerTempStorage.getInstance(  );
instance.store( 'BaseWorkspaceVars', vars );
locAssignVars( vars );
end 

function locAssignVars( vars )
fields = fieldnames( vars );
simulink.multisim.internal.debuglog( "Assigning variables to base workspace:" + strjoin( fields ) );
for i = 1:numel( fields )
assignin( 'base', fields{ i }, vars.( fields{ i } ) );
end 
end 

function locReassignVarsAndClearCache(  )
instance = MultiSim.internal.WorkerTempStorage.getInstance(  );
vars = instance.get( 'BaseWorkspaceVars' );
instance.store( 'BaseWorkspaceVars', [  ] );
locAssignVars( vars );
end 

function locDepAnalysisError( n, ME, modelName )
err = MException( message( 'Simulink:Commands:ErrorAnalyzingFile', n.Location{ 1 } ) );
msld = MSLDiagnostic( err );
msld = msld.addCause( MSLDiagnostic( ME ) );
msld.reportAsError( modelName, false );
end 

function locCacheWorkerInitialDirectory
currDir = pwd;
simulink.multisim.internal.debuglog( "Caching worker current directory " + currDir );
instance = MultiSim.internal.WorkerTempStorage.getInstance(  );
instance.store( 'WorkerInitialDir', currDir );
end 

function locSetupWorkerCacheFolder(  )
instance = MultiSim.internal.WorkerTempStorage.getInstance(  );

tempFolder = tempname;
instance.store( 'CacheFolder', tempFolder );

cfg = Simulink.fileGenControl( 'getConfig' );
workerSlprj = tempFolder;
cfg.CacheFolder = workerSlprj;
cfg.CodeGenFolder = workerSlprj;
Simulink.fileGenControl( 'setConfig', 'config', cfg, 'createDir', true );
simulink.multisim.internal.debuglog( "Setting cache folder to " + workerSlprj );

currDir = pwd;
instance.store( 'CWD', currDir );
addpath( currDir, '-frozen' );
end 

function locCopyCacheFilesIntoCacheFolder( workerCacheFolder )


perHostCacheFolder = parallel.pool.getPerHostFolder( workerCacheFolder );
instance = MultiSim.internal.WorkerTempStorage.getInstance(  );
workerCacheFolder = instance.get( 'CacheFolder' );
simulink.multisim.internal.debuglog( "Copying cache files from " + perHostCacheFolder + " to " + workerCacheFolder );
copyfile( perHostCacheFolder, workerCacheFolder );
end 

function locResetCurrentDir(  )
instance = MultiSim.internal.WorkerTempStorage.getInstance(  );

workerInitialDir = instance.get( 'WorkerInitialDir' );
simulink.multisim.internal.debuglog( "Changing directory to " + workerInitialDir );
cd( workerInitialDir );
rmpath( instance.get( 'CWD' ) );

simulink.multisim.internal.debuglog( "Closing all models" );
bdclose( 'all' );
simulink.multisim.internal.debuglog( "Resetting fileGenControl" );
Simulink.fileGenControl( 'reset' );
end 

function locClearWorkerCacheFolder(  )
instance = MultiSim.internal.WorkerTempStorage.getInstance(  );
workerCacheFolder = instance.get( 'CacheFolder' );
simulink.multisim.internal.debuglog( "Removing worker cache folder " + workerCacheFolder );
rmdir( workerCacheFolder, 's' );
end 

function locSetupWorkerDataDictionaryCache(  )
if strcmp( Simulink.dd.defaultCachePath, Simulink.dd.cachePath )
simulink.multisim.internal.debuglog( "Setting up data dictionary worker cache" );
Simulink.data.dictionary.setupWorkerCache(  );
end 
end 

function locCdToCacheFolder(  )
cfg = Simulink.fileGenControl( 'getConfig' );
simulink.multisim.internal.debuglog( "Changing directory to " + cfg.CacheFolder );
cd( cfg.CacheFolder );
end 

function locCloseProject(  )
instance = MultiSim.internal.WorkerTempStorage.getInstance(  );
project = instance.get( 'parsimProject' );
if ~isempty( project )
simulink.multisim.internal.debuglog( "Closing project" );
project.close(  );
end 
instance.store( 'parsimProject', [  ] );
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpKNIR2M.p.
% Please follow local copyright laws when handling this file.

