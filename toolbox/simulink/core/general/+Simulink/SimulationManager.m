



classdef ( Hidden = true )SimulationManager < handle
properties ( Dependent )
SimulationInputs
end 

properties ( SetAccess = public, GetAccess = public )
SimulationData
SimulationMetadata
Options
Errors
TotalExecutionTime
end 

properties ( Dependent )
NumSims
end 

properties ( Transient, Access = private )
SimulationFinishedFlag
SimOutputReceivedFlag
StartTic
ParallelPoolAvailable
ExecuteCompleted
CleanupExecuted
ParallelExecutionState
AllBackgroundSimulationsFinishedRunning
SimulationAbortInProcess
WaitForSimulationOutputs
AllSimulationsQueuedFlag
SDIPCTSupportMode
end 

properties ( Transient, SetAccess = private )
SimulationRunner
NumWorkers
end 

properties ( Transient, SetAccess = immutable )
ForRunAll( 1, 1 )logical
end 

properties ( Transient, Hidden = true )






AutoCleanup = true;
end 

properties ( SetAccess = private )






SingleSimOutputType


SimulationManagerEngine

AllModelNames
end 

properties ( SetAccess = private, GetAccess = ?simmanager.designview.FigureManager )
ActualSimulationInputs
SimInputSize
end 

properties ( Hidden = true )
ModelName
end 

properties ( SetAccess = public, GetAccess = public, Hidden = true )
URL
end 

properties ( Constant, Hidden )
DefaultSimulationMetadata = struct( 'ModelInfo', [  ],  ...
'TimingInfo', [  ],  ...
'ExecutionInfo', [  ],  ...
'UserString', '',  ...
'UserData', [  ] );
end 

events 
SimulationFinished


ProgressMessageGenerated


AbortSimulations
SimulationAborted

JobStarted
JobFinished
NumWorkersKnown

AllSimulationsQueued



ExecuteReturned
end 

methods 

function obj = SimulationManager( simInputsOrModelName, forRunAll )
R36
simInputsOrModelName
forRunAll( 1, 1 )logical = false
end 

obj.ForRunAll = forRunAll;

if ischar( simInputsOrModelName )

obj.ModelName = simInputsOrModelName;
obj.ActualSimulationInputs = Simulink.SimulationInput.empty;
obj.AllModelNames = { simInputsOrModelName };
else 

simInputs = simInputsOrModelName;
if isempty( simInputs ) || ~isa( simInputs, 'Simulink.SimulationInput' )
error( message( 'Simulink:Commands:InvalidSimInputArray' ) );
end 
obj.ModelName = obj.getUniqueModel( simInputs );
obj.SimInputSize = size( simInputs );
obj.ActualSimulationInputs = reshape( simInputs, 1, numel( simInputs ) );
end 


p = MultiSim.internal.ParsimInputParser( false );
parse( p, struct );
obj.Options = p.Results;

obj.Errors = [  ];
obj.SimulationData = {  };
obj.SimulationMetadata = {  };
obj.TotalExecutionTime = [  ];
obj.SimulationManagerEngine = Simulink.SimulationManagerEngine( obj );
end 

function delete( obj )
delete( obj.SimulationRunner );
end 

function simInps = get.SimulationInputs( obj )
simInps = obj.ActualSimulationInputs;
end 

function set.SimulationInputs( obj, ins )
if isempty( ins ) || ~isa( ins, 'Simulink.SimulationInput' )
error( message( 'Simulink:Commands:InvalidSimInputArray' ) );
end 
assert( ~isempty( obj.ModelName ),  ...
'ModelName on SimulationManager must not be empty' );
modelName = obj.getUniqueModel( ins );
assert( strcmp( modelName, obj.ModelName ),  ...
[ 'Model name in array of SimulationInput object (' ...
, modelName, ') must be the same as on the SimulationManager (' ...
, obj.ModelName, ')' ] );
obj.SimInputSize = size( ins );
obj.ActualSimulationInputs = reshape( ins, 1, numel( ins ) );
end 

function set.SimulationFinishedFlag( obj, newValue )
oldValue = obj.SimulationFinishedFlag;
obj.SimulationFinishedFlag = newValue;





if ( obj.Options.RunInBackground &&  ...
~obj.Options.ShowSimulationManager &&  ...
~all( oldValue ) && all( newValue ) && obj.AutoCleanup )
obj.AllBackgroundSimulationsFinishedRunning = true;
if ( obj.SimulationAbortInProcess )
return ;
else 
obj.cleanup(  );
end 
end 
end 

function set.SimOutputReceivedFlag( obj, newValue )
oldValue = obj.SimOutputReceivedFlag;
obj.SimOutputReceivedFlag = newValue;





if ( obj.Options.RunInBackground &&  ...
obj.Options.ShowSimulationManager &&  ...
~all( oldValue ) && all( newValue ) )
obj.AllBackgroundSimulationsFinishedRunning = true;
if ( obj.SimulationAbortInProcess )
return ;
else 
obj.cleanup(  );
end 
end 
end 

function numSims = get.NumSims( obj )
numSims = numel( obj.ActualSimulationInputs );
end 


function out = run( obj )
out = obj.execute( @sim );
end 

function set.Options( obj, value )





validateattributes( value, { 'struct' }, { 'scalar' } );
allowParallel = true;
if isfield( value, 'AllowParallelSimulations' )
allowParallel = value.AllowParallelSimulations;

value = rmfield( value, 'AllowParallelSimulations' );
end 

p = MultiSim.internal.ParsimInputParser( false );
p.AllowParallelSimulations = allowParallel;
parse( p, value );
unmatchedParams = fieldnames( p.Unmatched );
if ~isempty( unmatchedParams )
error( message( 'Simulink:Commands:InvalidParam', unmatchedParams{ 1 } ) );
end 
oldOptions = obj.Options;
obj.Options = p.Results;


usingDefaults = p.UsingDefaults;
for i = 1:numel( usingDefaults )
obj.Options.( usingDefaults{ i } ) = oldOptions.( usingDefaults{ i } );
end 
end 

function createSimulationInputs( obj, num )
if ~isempty( obj.ActualSimulationInputs )
DAStudio.error( 'Simulink:Commands:NonEmptySimInputArray' );
end 
obj.ActualSimulationInputs( 1:num ) = Simulink.SimulationInput( obj.ModelName );
end 

function clearSimulationInputs( obj )
obj.ActualSimulationInputs = Simulink.SimulationInput.empty;
end 

function cancel( obj, runId )
if nargin == 1

runId = [  ];
end 

if ~isempty( obj.SimulationRunner )

obj.SimulationRunner.cancel( runId );
end 
end 

function out = progress( obj )

out = sum( obj.SimOutputReceivedFlag );
end 

function out = connectToSimulation( obj, runId )
out = obj.SimulationRunner.connectToSimulation( runId );
end 
end 

methods ( Hidden = true, Access = { ?Simulink.SimulationManagerEngine } )



function setup( obj )
obj.CleanupExecuted = false;
obj.ParallelExecutionState = [  ];
obj.TotalExecutionTime = [  ];
obj.AllSimulationsQueuedFlag = false;

if isempty( obj.StartTic )
obj.StartTic = tic;
end 

notify( obj, 'JobStarted' );



[ ~, obj.SDIPCTSupportMode ] = Simulink.sdi.isPCTSupportEnabled(  );





obj.loadProject(  );


obj.setSimulationRunnerAndOutputType(  );
assert( isa( obj.SimulationRunner, 'MultiSim.internal.SimulationRunner' ),  ...
'Simulink:MultiSim:InvalidSimulationRunner',  ...
'SimulationManager:execute obj.SimulationRunner is not valid' );


numWorkers = obj.NumWorkers;
assert( isnumeric( numWorkers ) && ~isempty( numWorkers ) );

msg.NumWorkers = numWorkers;
msg.IsParallelRun = obj.useParallelExecution(  );
eventData = MultiSim.internal.SimulationManagerEventData( msg );
notify( obj, 'NumWorkersKnown', eventData );





addlistener( obj.SimulationRunner, 'SimulationOutputAvailable',  ...
@obj.handleSimulationOutputAvailable );


addlistener( obj.SimulationRunner, 'SimulationAborted',  ...
@obj.handleSimulationAborted );

addlistener( obj.SimulationRunner, 'SimulationFinishedRunning',  ...
@obj.handleSimulationFinishedRunning );

addlistener( obj.SimulationRunner, 'AllSimulationsQueued',  ...
@obj.handleAllSimulationsQueued );


addlistener( obj.SimulationRunner, 'ProgressMessageGenerated',  ...
@( ~, eventData )obj.showProgress( eventData ) );

obj.ActualSimulationInputs = obj.SimulationRunner.setup( obj.ActualSimulationInputs );
end 

function out = executeSims( obj, fh )
obj.Errors = [  ];
if isempty( obj.ActualSimulationInputs )
error( message( 'Simulink:Commands:EmptySimInputArray' ) );
end 


assert( isa( obj.SimulationRunner, 'MultiSim.internal.SimulationRunner' ),  ...
'Simulink:MultiSim:InvalidSimulationRunner',  ...
'SimulationManager:execute obj.SimulationRunner is not valid' );

numSims = numel( obj.ActualSimulationInputs );



[ M, N ] = size( obj.ActualSimulationInputs );
obj.SimulationData = cell( M, N );
obj.SimulationData( : ) = { struct };
obj.SimulationMetadata = cell( M, N );
obj.SimulationMetadata( : ) = { obj.DefaultSimulationMetadata };

obj.SimulationFinishedFlag = false( 1, numSims );
obj.SimOutputReceivedFlag = false( 1, numSims );

obj.AllBackgroundSimulationsFinishedRunning = false;
obj.SimulationAbortInProcess = false;




simInputs = obj.ActualSimulationInputs;
for i = 1:numSims
simInputs( i ).RunId = i;
end 
obj.ActualSimulationInputs = simInputs;


obj.showProgress( obj.SimulationRunner.MultiSimRunningMessage );


tmpOut = obj.SimulationRunner.executeImpl( fh, obj.ActualSimulationInputs );

if obj.WaitForSimulationOutputs


ctrlcCleanup = onCleanup( @(  )obj.handleJobFinished(  ) );



if obj.Options.ShowSimulationManager
while ~all( obj.SimOutputReceivedFlag )
pause( 0.01 );
end 
else 
obj.SimulationRunner.assignOutputsOnSimManager(  );
end 
out = Simulink.SimulationOutput( obj.SimulationData, obj.SimulationMetadata );
else 
out = tmpOut;
end 
end 


function cleanup( obj )

if obj.CleanupExecuted
return ;
end 
obj.CleanupExecuted = true;

if ~isempty( obj.SimulationRunner )
obj.SimulationRunner.cleanup(  );






end 
obj.AllBackgroundSimulationsFinishedRunning = false;
obj.SimulationAbortInProcess = false;
obj.ParallelExecutionState = [  ];
notify( obj, 'JobFinished' );

obj.TotalExecutionTime = toc( obj.StartTic );


[ ~, currentMode ] = Simulink.sdi.isPCTSupportEnabled(  );
if ~strcmp( currentMode, obj.SDIPCTSupportMode )
Simulink.sdi.enablePCTSupport( obj.SDIPCTSupportMode );
end 
end 
end 

methods ( Hidden = true )



function out = execute( obj, fh )

out = [  ];
obj.StartTic = tic;
obj.ExecuteCompleted = false;
obj.CleanupExecuted = false;
interruptHandler = onCleanup( @(  )obj.handleInterrupt(  ) );

try 
if isempty( obj.ActualSimulationInputs )
error( message( 'Simulink:Commands:EmptySimInputArray' ) );
end 


if ( ~obj.Options.AllowMultipleModels && numel( obj.AllModelNames ) ~= 1 ) ...
 || isempty( obj.ModelName )
error( message( 'Simulink:Commands:DifferentModelsInArrayOfSimInput' ) );
end 


obj.loadProject(  );

numSims = numel( obj.ActualSimulationInputs );
obj.SimOutputReceivedFlag = false( 1, numSims );

obj.setup(  );

outVector = obj.executeSims( fh );
out = reshape( outVector, obj.SimInputSize );
catch ME
obj.ExecuteCompleted = true;

obj.cleanup(  );

cancelRequested = ~isempty( obj.SimulationRunner ) && obj.SimulationRunner.CancelRequested;
ignoreErrors = cancelRequested && obj.ForRunAll;
if ~ignoreErrors
throwAsCaller( ME );
end 
end 


if isa( out, 'Simulink.SimulationOutput' )
obj.cleanup(  );
end 
obj.ParallelExecutionState = [  ];
obj.ExecuteCompleted = true;
end 

function dispatchRunsIfNeeded( obj )
obj.SimulationRunner.dispatchRunsIfNeeded(  );
end 


function handleSimulationOutputAvailable( obj, ~, eventData )
runId = eventData.RunId;
simOut = eventData.SimulationOutput;
[ obj.SimulationData( runId ), obj.SimulationMetadata( runId ) ] =  ...
simOut.getInternalSimulationDataAndMetadataStructs(  );
obj.updateFinalStatus( runId );


finishedEventData =  ...
Simulink.internal.SimulationFinishedEventData( runId, simOut );
obj.notify( 'SimulationFinished', finishedEventData );

end 


function handleSimulationAborted( obj, ~, eventData )

if ( ~eventData.Cancelled )
obj.SimulationAbortInProcess = true;
return ;
end 
runIds = eventData.RunIds;

if isempty( runIds )
return ;
end 
fullAbort = numel( runIds ) == obj.SimulationRunner.NumSims;




validRunIds = runIds( runIds > 0 );
abortedRunIds = validRunIds( ~obj.SimOutputReceivedFlag( validRunIds ) );
if isempty( abortedRunIds )

return ;
end 

obj.abortSimulations( fullAbort, abortedRunIds );
end 

function handleSimulationFinishedRunning( obj, ~, eventData )
runId = eventData.Data.RunId;
obj.SimulationFinishedFlag( runId ) = true;
end 

function handleAllSimulationsQueued( obj, ~, eventData )
obj.AllSimulationsQueuedFlag = true;
obj.notify( 'AllSimulationsQueued', eventData );
end 

function finalizeRun( obj )


if ~obj.ForRunAll && ~isempty( obj.Errors ) &&  ...
isa( obj.SingleSimOutputType, 'Simulink.SimulationOutput' )
indexStr = mat2str( sort( [ obj.Errors.RunID ] ) );


if numel( obj.Errors ) == 1
indexStr = [ '[', indexStr, ']' ];
end 

indexStr = strjoin( { '', indexStr }, '\n' );


ME = MException( message( 'Simulink:Commands:SimulationsWithErrors', indexStr ) );
obj.reportAsWarning( ME );
end 
end 


function canUse = useParallelExecution( obj )


oc = onCleanup( @(  )obj.checkParallelExecutionState(  ) );

if ( ~isempty( obj.ParallelExecutionState ) )
canUse = obj.ParallelExecutionState;
return ;
end 

canUse = false;
if ~obj.Options.UseParallel
obj.ParallelExecutionState = canUse;
obj.NumWorkers = 1;
return ;
end 





obj.errorOutIfModelsAreDirty(  );

obj.warnAboutUnsavedDataDictionaries(  );


if isempty( obj.ParallelPoolAvailable )
obj.showProgress( message( 'Simulink:MultiSim:ParpoolAvailabilityCheck' ) );

canUse = matlab.internal.parallel.canUseParallelPool(  );
obj.ParallelPoolAvailable = canUse;
if ~canUse
obj.NumWorkers = 1;
else 
p = gcp;
obj.NumWorkers = p.NumWorkers;
end 
else 
canUse = obj.ParallelPoolAvailable;
end 
obj.ParallelExecutionState = canUse;
end 

function setSimulationData( obj, simData )
obj.SimulationData = simData;
end 

function setSimulationMetadata( obj, simMetadata )
obj.SimulationMetadata = simMetadata;
end 

function origSimIns = getOriginalSimulationInputs( obj )
origSimIns = reshape( obj.SimulationInputs, obj.SimInputSize );
end 
end 

methods ( Access = private )
function modelName = getUniqueModel( obj, simInputs )
modelNames = { simInputs.ModelName };
modelNames = cellfun( @( x )convertStringsToChars( x ), modelNames, 'UniformOutput', false );

uniqueModelNames = unique( modelNames );
obj.AllModelNames = uniqueModelNames;
modelName = uniqueModelNames{ 1 };
end 

function errorOutIfModelsAreDirty( obj )
load_system( obj.AllModelNames );
isDirty = strcmpi( get_param( obj.AllModelNames, 'Dirty' ), 'on' );
if any( isDirty )
dirtyModelNames = strjoin( obj.AllModelNames( isDirty ), ", " );
err = MException( message( 'Simulink:Commands:ParsimUnsavedChanges', dirtyModelNames ) );
msld = MSLDiagnostic( err );
msld.reportAsError( obj.ModelName, false );
end 
end 

function warnAboutUnsavedDataDictionaries( obj )
openDictionaryPaths = Simulink.data.dictionary.getOpenDictionaryPaths(  );



if isempty( openDictionaryPaths )
return ;
end 

isDictionaryDirty = false( 1, numel( openDictionaryPaths ) );

for modelIdx = 1:numel( obj.AllModelNames )
dictionariesUsedByModel = MultiSim.internal.getDataDictionariesUsedByModel( obj.AllModelNames{ modelIdx } );
[ dictionariesToCheck, ~, openDictionaryPathsIdx ] = intersect( dictionariesUsedByModel, openDictionaryPaths );


for ddIdx = 1:numel( dictionariesToCheck )
dd = Simulink.data.dictionary.open( dictionariesToCheck{ ddIdx } );
if dd.HasUnsavedChanges
isDictionaryDirty( openDictionaryPathsIdx( ddIdx ) ) = true;
end 
end 
end 

if any( isDictionaryDirty )
dirtyDictionaryPaths = dictionariesToCheck( isDictionaryDirty );
dirtyDictionaryPathsStr = strjoin( dirtyDictionaryPaths, newline );
warningException = MException( message( 'Simulink:Commands:ParsimUnsavedChangesDataDictionary', dirtyDictionaryPathsStr ) );
obj.reportAsWarning( warningException );
end 
end 

function setSimulationRunnerAndOutputType( obj )
if obj.useParallelExecution(  )
pool = gcp;
if MultiSim.internal.useLightweightWorkers( obj.ActualSimulationInputs, obj.Options, pool )
if isa( pool, 'parallel.ThreadPool' )
obj.SimulationRunner =  ...
MultiSim.internal.SimulationRunnerRapidThreads( obj );
elseif isa( pool.Cluster, 'parallel.cluster.Local' )
obj.SimulationRunner =  ...
MultiSim.internal.SimulationRunnerRapidLocal( obj );
else 
obj.SimulationRunner =  ...
MultiSim.internal.SimulationRunnerRapidMJS( obj );
end 
obj.SingleSimOutputType = Simulink.SimulationOutput;
else 


if obj.Options.RunInBackground


q = pool.FevalQueue;
if numel( q.RunningFutures ) > 0 || numel( q.QueuedFutures ) > 0
error( message( 'Simulink:Commands:ParsimBusyPool' ) );
end 
obj.SingleSimOutputType = Simulink.Simulation.Future;
else 
obj.SingleSimOutputType = Simulink.SimulationOutput;
end 



parallel.internal.pool.yield(  );


if isa( pool.Cluster, 'parallel.cluster.Local' )
obj.SimulationRunner =  ...
MultiSim.internal.SimulationRunnerParallelLocal( obj );
else 
obj.SimulationRunner =  ...
MultiSim.internal.SimulationRunnerParallelMJS( obj );
end 
end 

performance.cooperativeTaskManager.finishTaskByName( 'JetstreamAsyncPerformanceCache' );
Simulink.sdi.enablePCTSupport( false );
else 
obj.SimulationRunner = MultiSim.internal.SimulationRunnerSerial( obj );
obj.SingleSimOutputType = Simulink.SimulationOutput;
end 
if ~isa( obj.SimulationRunner.SingleSimOutputType, class( obj.SingleSimOutputType ) )
obj.WaitForSimulationOutputs = true;
end 
end 




function updateFinalStatus( obj, runId )
oldValue = obj.SimOutputReceivedFlag;
obj.SimOutputReceivedFlag( runId ) = true;
numFinished = sum( obj.SimOutputReceivedFlag );
numSims = numel( obj.SimOutputReceivedFlag );
outputHasErrors = false;


md = obj.SimulationMetadata{ runId };
errDiagnostic = [  ];
if ~isempty( md ) && isfield( md, 'ExecutionInfo' ) &&  ...
~isempty( md.ExecutionInfo )
errDiagnostic = md.ExecutionInfo.ErrorDiagnostic;
end 

if ~isempty( errDiagnostic )
if isempty( obj.Errors )
obj.Errors = struct( 'RunID', {  }, 'Message', {  }, 'Diagnostic', {  } );
end 

obj.Errors( end  + 1 ) = struct( 'RunID', runId, 'Message', errDiagnostic.Diagnostic.message,  ...
'Diagnostic', errDiagnostic.Diagnostic );
msg = message( 'Simulink:Commands:MultiSimProgressError',  ...
numFinished, numSims, runId );
outputHasErrors = true;
else 
msg = message( 'Simulink:Commands:MultiSimProgress',  ...
numFinished, numSims );
end 


if isa( obj.SingleSimOutputType, 'Simulink.SimulationOutput' )
obj.showProgress( msg );
end 

if outputHasErrors && obj.Options.StopOnError
obj.cancel(  );
obj.Options.ShowProgress = false;
end 

newValue = obj.SimOutputReceivedFlag;




if ~all( oldValue ) && all( newValue )
obj.finalizeRun(  );
end 

end 

function showProgress( obj, eventData )
if isa( eventData, 'MultiSim.internal.ProgressMessageEventData' )
msg = eventData.Message;
else 
msg = eventData;
eventData = MultiSim.internal.ProgressMessageEventData( msg );
end 
validateattributes( msg, { 'message' }, { 'scalar' } );
if obj.Options.ShowProgress
fprintf( '[%s] %s\n', eventData.Time, getString( msg ) );
end 
obj.notify( 'ProgressMessageGenerated', eventData );
end 

function handleProgressMessage( obj, ~, eventData )
msg = eventData.Message;
obj.showProgress( msg );
end 

function handleJobFinished( obj )
if ~isempty( obj.SimulationRunner )
obj.SimulationRunner.cancel(  )
end 
end 



function reportAsWarning( obj, ME )

warnState = warning( 'query', 'backtrace' );
oc = onCleanup( @(  )warning( warnState ) );
warning off backtrace;
msld = MSLDiagnostic( ME );
msld.reportAsWarning( obj.ModelName, false );
end 

function checkParallelExecutionState( obj )
if isempty( obj.ParallelExecutionState )
obj.cleanup(  );
end 
end 

function handleInterrupt( obj )
notify( obj, 'ExecuteReturned' );

if ~obj.ExecuteCompleted
obj.cleanup(  )
end 


if ~obj.AllSimulationsQueuedFlag
obj.abortSimulations( true, 1:numel( obj.SimulationInputs ) );
end 
end 

function abortSimulations( obj, fullAbort, abortedRunIds )






abortedEventData = MultiSim.internal.SimulationAbortedEventData(  ...
fullAbort, abortedRunIds );

obj.notify( 'AbortSimulations', abortedEventData );
msgId = 'Simulink:Commands:SimAborted';
ME = MException( msgId, message( msgId ).getString(  ) );
metadataWrapper = Simulink.SimMetadataWrapper( obj.ModelName );
metaStruct = metadataWrapper.matlabStruct( 1 );

md = obj.DefaultSimulationMetadata;
md.ModelInfo = metaStruct.ModelInfo;
md.TimingInfo = metaStruct.TimingInfo;
md.ExecutionInfo = metaStruct.ExecutionInfo;
md.ExecutionInfo.StopEvent = 'DiagnosticError';
md.ExecutionInfo.StopEventDescription = ME.message;
md.ExecutionInfo.ErrorDiagnostic =  ...
struct( 'Diagnostic', MSLDiagnostic( ME ) );
obj.SimulationMetadata( abortedRunIds ) = { md };
obj.notify( 'SimulationAborted', abortedEventData );
obj.SimOutputReceivedFlag( abortedRunIds ) = true;
obj.SimulationAbortInProcess = false;



if ( obj.AllBackgroundSimulationsFinishedRunning )
obj.cleanup(  );
end 
end 

function loadProject( obj )

fileToProjectMapper = Simulink.ModelManagement.Project.Util.FileToProjectMapper( which( obj.ModelName ) );
projectRoot = fileToProjectMapper.ProjectRoot;

if isempty( projectRoot ) || ~MultiSim.internal.isProjectLoaded( projectRoot )


return ;
end 

modelIsInReferencedProject = false;
for curProject = slproject.getCurrentProjects(  )
modelIsInReferencedProject = MultiSim.internal.isReferencedInProject( projectRoot, curProject );
if modelIsInReferencedProject
break ;
end 
end 


if ~fileToProjectMapper.InRootOfALoadedProject && ~modelIsInReferencedProject
simulinkproject( projectRoot );
end 
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpdwfDAV.p.
% Please follow local copyright laws when handling this file.

