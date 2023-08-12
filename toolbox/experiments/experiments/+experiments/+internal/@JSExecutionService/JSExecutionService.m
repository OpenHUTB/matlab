classdef JSExecutionService < handle




properties ( Access = { ?matlab.mock.TestCase } )
isExpRunning = false;
stopAndCancel = false;
canceledTrials = [  ];
currentTrial = [  ];
isClassification = false;

dataQueue;
afterEachFuture;
futureTrialInfoMap;
isPostProcessingDone = [  ];
poolObj;
stopDataQueueMap;
completedWorker;
endOfLoop = false;
end 

properties 
execInfo = [  ];
parallelToggleOn = false;
trialRunnerMap;
end 

properties ( Constant )
usageDataId = matlab.ddux.internal.DataIdentification( "NN", "NN_EXPERIMENT_MANAGER", "NN_EXPERIMENT_MANAGER_RUN" );
end 

methods 


function cancelTrial( this, trialID )























runID = this.execInfo.runID;
curTrial = this.rsGetRun( runID ).data{ trialID };
if this.parallelToggleOn || strcmp( curTrial{ 2 }.status, 'Queued' )
curTrial{ 2 }.status = 'Canceled';
res.rowInd = trialID - 1;



if ~this.parallelToggleOn
res.rowData = this.rsUpdateTrial( runID, trialID, curTrial );
this.emit( [ 'updateRow/', this.rsGetRun( runID ).uuid ], res );
else 
res.rowData = curTrial;
end 
end 



if this.parallelToggleOn
data.runID = runID;
data.trialID = trialID;
data.res = res;
data.paramList = '';
this.saveAndCleanUpParallel( data );
end 
end 

function execExperimentStopAndCancel( this, closeWindow )
this.stopAndCancel = true;
this.execExperimentStop( closeWindow );
end 

function updateStopValueOnPool( this, value )
if isprop( this.poolObj, 'ValueStore' )


this.poolObj.ValueStore( "Stop" ) = value;
end 
end 


function execExperimentStop( this, closeWindow )









this.isExpRunning = false;

if closeWindow
delete( this.cef );
return ;
end 
if isempty( this.execInfo )
return ;
end 
cleanupSaveResults = this.suspendSaveResult(  );

if ~this.parallelToggleOn
if ~isempty( this.execInfo.workerDQ )
this.execInfo.workerDQ.send( {  } );
end 
this.execInfo.trialRunner.setStopOnMonitor(  );
else 
this.updateStopValueOnPool( 0 );
if ~this.execInfo.isBayesOptExp

if isempty( this.futureTrialInfoMap ) || isempty( this.trialRunnerMap )





return ;
end 

trialInfoEntries = cell2mat( values( this.futureTrialInfoMap ) );
trialIDs = [ trialInfoEntries.trialID ];
futureTrialInfos = [ trialInfoEntries.futureTrialInfo ];







states = { futureTrialInfos.State };
if ( this.stopAndCancel )
queuedMask = ismember( states, [ "pending", "queued", "running" ] );
runningMask = [  ];
else 
queuedMask = ismember( states, [ "pending", "queued" ] );
runningMask = states == "running";
end 



cancel( fliplr( futureTrialInfos( queuedMask ) ) );



for index = find( runningMask )
trialID = trialIDs( index );


if isKey( this.stopDataQueueMap, trialID )
send( this.stopDataQueueMap( trialID ), {  } );
end 
end 


for index = find( queuedMask )
trialID = trialIDs( index );






if ~isKey( this.completedWorker, trialID )
this.cancelTrial( trialID );
end 
end 

else 
trialRunnerKeys = keys( this.trialRunnerMap );
for trialID = trialRunnerKeys
send( this.stopDataQueueMap( trialID{ 1 } ), {  } );
end 
end 
end 
end 

function execSetParallelToggle( this, value )
this.parallelToggleOn = value;
end 

function execExperimentStartRun( this )
this.startExecution(  );
end 

function execInfo = getExecInfo( this )
execInfo = this.execInfo;
end 

function parallelLicenseCheck( this )
experiments.internal.PCTLicenseCheck(  );
if isempty( this.dataQueue )
this.initDataQAndTrialRunnerMap(  );
end 
end 

function initDataQAndTrialRunnerMap( this )
this.afterEachFuture = parallel.FevalFuture.empty;
this.futureTrialInfoMap = containers.Map( 'KeyType', 'double', 'ValueType', 'any' );
this.trialRunnerMap = containers.Map( 'KeyType', 'double', 'ValueType', 'any' );
this.stopDataQueueMap = containers.Map( 'KeyType', 'double', 'ValueType', 'any' );
this.completedWorker = containers.Map( 'KeyType', 'double', 'ValueType', 'any' );
this.dataQueue = experiments.internal.MultiplexedDataQueue(  );
afterEach( this.dataQueue, @this.handleWorkerData );
end 

function bayesoptLicenseCheck( ~, expDef )
import experiments.internal.ExperimentException

isBayesOptExp = ~( strcmp( expDef.ExperimentType, 'ParamSweep' ) );
if ~isBayesOptExp
return 
end 

if isempty( ver( 'stats' ) )
throw( ExperimentException( message( 'experiments:manager:NoBayesoptInstalled' ) ) );
end 
if ~builtin( 'license', 'test', 'Statistics_Toolbox' )
throw( ExperimentException( message( 'experiments:manager:NoBayesoptLicense' ) ) );
end 

[ success, errmsg ] = builtin( 'license', 'checkout', 'Statistics_Toolbox' );
if ~success
throw( ExperimentException( message( 'experiments:manager:BayesoptLicenseCheckoutFailure', errmsg ) ) );
end 
end 

function runInfo = execExperimentInitRun( this, expDef, runParallal, runBatch )
R36
this
expDef
runParallal =  - 1
runBatch = false
end 
if runParallal > 0
this.parallelToggleOn = ( runParallal == 2 );
end 
if this.parallelToggleOn && ~runBatch



this.parallelLicenseCheck(  );
end 
this.bayesoptLicenseCheck( expDef );

curDir = pwd;
cleanupObj1 = onCleanup( @(  )cd( curDir ) );
cd( this.currentProject.rootDir );

import experiments.internal.ExperimentException
[ runInfo, expInputList ] = experiments.internal.utils.ExecutionUtils.initializeRunInfo( this, expDef );

if ~isempty( runInfo.error )

return ;
end 
runID = runInfo.runID;
isBayesOptExp = ~( strcmp( expDef.ExperimentType, 'ParamSweep' ) );
isCustomExperiment = strcmp( expDef.Process.Type, 'CustomTraining' );
snapshotDir = fullfile( this.getRunDir( runID ), 'Snapshot' );
if ~runBatch
this.createParallelPoolAndAttachFiles( snapshotDir );
end 
if isBayesOptExp
params = { expInputList.getFirstBayesoptTrial(  ) };
nTrial = 1;
else 
expInputList.setExecMode( expDef.ExecMode );
nTrial = expInputList.getNumTrials(  );
expInputList.initExecution(  );
params = cell( 1, nTrial );
for i = 1:nTrial
params{ i } = expInputList.getNextTrial(  );
end 
end 
paramStruct = this.constructParamStruct( runInfo.paramList, params{ 1 } );
this.execInfo.runBatch = runBatch;
if runBatch
runInfo.trainingType = 'Unknown';
runInfo.usesValidation = false;
stdMetrics = {  };

runInfo.OptimizableMetric = expDef.Process.OptimizableMetricData;
runInfo.FirstParam = params{ 1 };
elseif ~isCustomExperiment
try 
setupFcn = expDef.Process.SetupFcn;
trainingFcn = '';
curTrial.runID = runInfo.runID;
curTrial.trialID = 0;
trialRunner = experiments.internal.TrialRunner( '', '', '', paramStruct, setupFcn, this.execInfo, curTrial, '', '', snapshotDir, '', '' );

if ~this.parallelToggleOn
trialDir = fullfile( this.getRunDir( runInfo.runID ), 'Trial_0' );
if ~isfolder( trialDir )
mkdir( trialDir );
end 
[ workerError, runInfo.trainingType, runInfo.usesValidation ] = trialRunner.getInputAndTrainingType( this.feature.mockTrainNetwork );
else 
trialRunner.isParallel = true;
executeSetupFcnFuture = parfeval( this.poolObj, @trialRunner.getInputAndTrainingType, 3, this.feature.mockTrainNetwork );
wait( executeSetupFcnFuture );
if ~isempty( executeSetupFcnFuture.Error )
if ~isempty( executeSetupFcnFuture.Error.remotecause )
rethrow( executeSetupFcnFuture.Error.remotecause{ 1 } );
else 
throw( executeSetupFcnFuture.Error );
end 
end 
[ workerError, runInfo.trainingType, runInfo.usesValidation ] = fetchOutputs( executeSetupFcnFuture );

end 
if ~isempty( workerError )
rethrow( workerError.ME );
end 
this.setIsClassification( strcmp( runInfo.trainingType, 'classification' ) );



optMetric = expDef.Process.OptimizableMetricData;
if isBayesOptExp && ~runInfo.usesValidation && ~isempty( optMetric )


if ( optMetric{ 1 } == 2 || optMetric{ 1 } == 3 )
ME = ExperimentException( message( 'experiments:editor:InvalidMetricSelection' ) );
throw( ME );
end 
end 

catch Mex
setupFcnErrorME = ExperimentException( message( 'experiments:editor:setupFcnError' ) );
setupFcnErrorME = setupFcnErrorME.addCause( ExperimentException( Mex ) );
prjPath = experiments.internal.JSProjectService.getCurrentProjectPath(  );
if ~exist( 'workerError', 'var' )
workerError = [  ];
end 
runInfo.error = experiments.internal.getErrorReportWithCauseCallStacks( setupFcnErrorME,  ...
'ProjectPath', prjPath,  ...
'WorkerError', workerError );

this.rsSetRun( runInfo );

return ;
end 
stdMetrics = { 'NA', 'NA' };
if runInfo.usesValidation
stdMetrics = [ stdMetrics, { 'NA', 'NA' } ];
end 

runInfo.OptimizableMetric = expDef.Process.OptimizableMetricData;


if runInfo.isBayesOpt && ~runInfo.usesValidation && runInfo.OptimizableMetric{ 1 } > 3
runInfo.OptimizableMetric{ 1 } = runInfo.OptimizableMetric{ 1 } - 2;
end 
else 
setupFcn = '';
trainingFcn = expDef.Process.TrainingFcn;
runInfo.trainingType = 'CustomTraining';
runInfo.usesValidation = false;
stdMetrics = {  };
runInfo.OptimizableMetric = expDef.Process.OptimizableMetricData;
end 

runInfo.stdMetrics = stdMetrics;

statusInfo = createStatusInfo( this, 'Queued', isCustomExperiment );
trialCompletionTime = struct( 'startTime', '', 'completionTime', '' );
if ~isBayesOptExp
runInfo.data = cell( nTrial, 1 );
mData = {  };
if ( ~isCustomExperiment && ~runBatch )
mData = runInfo.metricData;
end 
if ~isempty( runInfo.paramList )
for i = 1:nTrial

for j = 1:length( runInfo.paramList )
runInfo.colValues.( 'Col_Input_' + runInfo.paramList( j ) ) =  ...
[ runInfo.colValues.( 'Col_Input_' + runInfo.paramList( j ) ), params{ i }{ j } ];
end 
runInfo.data{ i } = [ { i, statusInfo, trialCompletionTime }, params{ i }, stdMetrics, mData ];
end 

for j = 1:length( runInfo.paramList )
runInfo.colValues.( 'Col_Input_' + runInfo.paramList( j ) ) = sort( runInfo.colValues.( 'Col_Input_' + runInfo.paramList( j ) ) );
end 
else 
for i = 1:nTrial
runInfo.data{ i } = [ { i, statusInfo, trialCompletionTime }, stdMetrics, mData ];
end 
end 
end 

if ~isCustomExperiment && ~runBatch
ouputColValues = this.genOutputColValues( runInfo );
for outputCol = fieldnames( ouputColValues )'
runInfo.colValues.( outputCol{ 1 } ) = ouputColValues.( outputCol{ 1 } );
end 
end 


this.rsSetRun( runInfo );
if runBatch
return ;
end 
this.setupExecutionInfo( runInfo.runID, 1:1:nTrial, setupFcn, trainingFcn, snapshotDir, runInfo.trainingType, runInfo.usesValidation );
if isBayesOptExp
this.setupBayesoptRelatedExecutionInfo( runInfo.optVars, runInfo.metricData, runInfo.stdMetrics, runInfo.OptimizableMetric, runInfo.BayesOptOptions );
end 
end 

function execRestartAllCanceledTrials( this, runID )
run = this.rsGetRun( runID ).data;
canceledTrialIds = [  ];
for trialID = 1:length( run )
curTrial = run{ trialID };
if isequal( curTrial{ 2 }.status, 'Canceled' )
canceledTrialIds( end  + 1 ) = trialID;
end 

end 
this.execExperimentRestartTrial( runID, canceledTrialIds );
end 

function execRestartAllTrials( this, runID, trialIDsToRestart )

trialIDsToRestart = trialIDsToRestart( : )';
if ~isempty( trialIDsToRestart )
this.execExperimentRestartTrial( runID, trialIDsToRestart );
end 
end 


function execExperimentRestartTrial( this, runID, trialIDs )
if this.parallelToggleOn
this.emit( 'enterAtomic', message( 'experiments:manager:StartParallelPoolSpinnerText' ).getString(  ) );
cleanup = onCleanup( @(  )this.emit( 'exitAtomic' ) );
this.parallelLicenseCheck(  );
clear cleanup;
end 


if ~this.parallelToggleOn
assert( this.isExpRunning == false, 'No experiment should be running' );
end 

runInfo = this.rsGetRun( runID );
expName = runInfo.expName;
filePath = fullfile( this.getRunDir( runID ), 'Snapshot', [ expName, '.mat' ] );
snapshotExperiment = matfile( filePath ).Experiment;
snapshotDir = fullfile( this.getRunDir( runID ), 'Snapshot' );

if runInfo.trainingType ~= "CustomTraining"
stdMetrics = { 'NA', 'NA' };
len = 2;
if runInfo.usesValidation
stdMetrics = [ stdMetrics, { 'NA', 'NA' } ];
len = len + 2;
end 
setupFcn = snapshotExperiment.Process.SetupFcn;
trainingFcn = '';
else 
stdMetrics = {  };
len = 0;
setupFcn = '';
trainingFcn = snapshotExperiment.Process.TrainingFcn;
end 

metricData = {  };
nMetrics = length( runInfo.Metrics );
if nMetrics > 0
len = len + nMetrics;
data = struct( 'value', 0, 'error', '', 'state', 'NA' );
[ metricData{ 1:nMetrics } ] = deal( data );
end 

infoData = {  };
nInfo = 0;
if isfield( runInfo, 'Info' )
nInfo = length( runInfo.Info );
end 
if nInfo > 0
len = len + nInfo;
data = struct( 'value', 0, 'error', '', 'state', 'NA' );
[ infoData{ 1:nInfo } ] = deal( data );
end 

cleanupSaveResults = this.suspendSaveResult(  );
for trialID = trialIDs

curTrial = runInfo.data{ trialID };
prevData = curTrial;
prevStatus = curTrial{ 2 }.status;

curTrial{ 2 } = createStatusInfo( this, 'Queued', strcmp( runInfo.trainingType, 'CustomTraining' ) );
trialCompletionTime = struct( 'startTime', '', 'completionTime', '' );
curTrial{ 3 } = trialCompletionTime;
curTrial( end  - len + 1:end  ) = [ stdMetrics, metricData, infoData ];
res.rowInd = trialID - 1;
res.rowData = this.rsUpdateTrial( runID, trialID, curTrial );
this.emit( [ 'updateRow/', runInfo.uuid ], res );



if strcmpi( prevStatus, 'Stopped' ) || strcmpi( prevStatus, 'Discarded' )
this.rsUpdateColumnValuesOnRestart( runID, prevData );
end 
end 

clear cleanupSaveResults;
this.createParallelPoolAndAttachFiles( snapshotDir );
this.setupExecutionInfo( runID, trialIDs, setupFcn, trainingFcn, snapshotDir, runInfo.trainingType, runInfo.usesValidation );

if runInfo.trainingType == "CustomTraining"
for i = 1:nMetrics
item = runInfo.Metrics( i );
this.execInfo.MetricsName2IndexMap( item.name ) = item.index + 1;
end 
for i = 1:nInfo
item = runInfo.Info( i );
this.execInfo.InfoName2IndexMap( item.name ) = item.index + 1;
end 
end 

this.startExecution(  );

end 


function execExperimentStopTrial( this, trialID )
if ~this.isExpRunning
return ;
end 

this.canceledTrials( end  + 1 ) = trialID;

if ~this.parallelToggleOn
if ~isempty( this.execInfo.workerDQ )
this.execInfo.workerDQ.send( {  } );
end 
this.cancelTrial( trialID );
this.execInfo.trialRunner.setStopOnMonitor(  );
else 
this.updateStopValueOnPool( trialID );
futureObj = this.futureTrialInfoMap( trialID ).futureTrialInfo;
futureObjState = futureObj.State;
if ismember( futureObjState, { 'pending', 'queued' } )
futureObj.cancel;
if ~isKey( this.completedWorker, trialID )
this.cancelTrial( trialID );
end 
elseif futureObjState == "running"


if isKey( this.stopDataQueueMap, trialID )
send( this.stopDataQueueMap( trialID ), {  } );
end 
end 

end 
end 



function endOfRun_Test( this, ~, ~ )
runID = this.execInfo.runID;
runInfo = this.rsGetRun( runID );
runInfo.completionTime = experiments.internal.getCurrentTimeString(  );
this.rsSetRun( runInfo );
this.isExpRunning = false;
this.execInfo = [  ];
this.canceledTrials = [  ];
this.emit( [ 'endRun/', runInfo.uuid ], experiments.internal.getCurrentTimeString(  ) );
this.emit( "endRun" );
end 
end 

methods 

function res = getIsExpRunning( this )
res = this.isExpRunning;
end 

function setIsClassification( this, val )
this.isClassification = val;
end 

function val = shouldStopTraining( this, curEpoch )
if this.feature.mockStopExperiment

if curEpoch > 5
val = [ true, this.stopAndCancel ];
this.isExpRunning = false;
else 
val = [ false, this.stopAndCancel ];
end 
return ;
end 
val = ~this.isExpRunning || any( this.canceledTrials == this.currentTrial.trialID );
if ~this.execInfo.isCustomExp

val = [ val, this.stopAndCancel ];
end 
end 

function setupExecutionInfo( this, runID, trialID, setupFcn, trainingFcn, snapshotDir, trainingType, usesValidation )
this.execInfo.runID = runID;
this.execInfo.trialID = trialID;
this.execInfo.setupFcn = setupFcn;
this.execInfo.trainingFcn = trainingFcn;
this.execInfo.snapshotDir = snapshotDir;
this.execInfo.trainingType = trainingType;
this.execInfo.usesValidation = usesValidation;
this.execInfo.isBayesOptExp = false;
this.execInfo.workerDQ = [  ];
this.execInfo.isCustomExp = ( trainingType == "CustomTraining" );
this.execInfo.InfoName2IndexMap = containers.Map( 'KeyType', 'char', 'ValueType', 'double' );
this.execInfo.MetricsName2IndexMap = containers.Map( 'KeyType', 'char', 'ValueType', 'double' );
this.execInfo.runBatch = false;
end 

function setupBayesoptRelatedExecutionInfo( this, optVars, metricData, stdMetrics, OptimizableMetricData, BayesOptOptions )
this.execInfo.optVars = optVars;
this.execInfo.isBayesOptExp = true;
this.execInfo.metricData = metricData;
this.execInfo.stdMetrics = stdMetrics;
this.execInfo.OptimizableMetricData = OptimizableMetricData;
this.execInfo.BayesOptOptions = BayesOptOptions;
end 

function trialRow = createTrialRow( this, trialID, params )

statusInfo = createStatusInfo( this, 'Queued', strcmp( this.execInfo.trainingType, 'CustomTraining' ) );
trialCompletionTime = struct( 'startTime', '', 'completionTime', '' );
metricData = {  };
stdMetrics = {  };
if ~strcmp( this.execInfo.trainingType, 'CustomTraining' )
metricData = this.execInfo.metricData;
stdMetrics = this.execInfo.stdMetrics;
else 
len = this.execInfo.InfoName2IndexMap.Count + this.execInfo.MetricsName2IndexMap.Count;
if len > 0
data = struct( 'value', 0, 'error', '', 'state', 'NA' );
[ metricData{ 1:len } ] = deal( data );
end 
end 
trialRow = [ { trialID, statusInfo, trialCompletionTime }, params, stdMetrics, metricData ];
end 
end 

methods ( Access = { ?matlab.mock.TestCase, ?experiments.internal.utils.ExecutionUtils, ?experiments.internal.BatchExecutionService } )

function runDir = createRunDir( this, runID )
runDir = this.getRunDir( runID );
mkdir( runDir );
end 

function snapshotDir = createSnapshotDir( this, runID )
snapshotDir = fullfile( this.getRunDir( runID ), 'Snapshot' );
if ~exist( snapshotDir, 'dir' )
mkdir( snapshotDir );
end 

end 

function runDir = getRunDir( this, runID )
runDir = fullfile( this.getResultsDir(  ), runID );
end 

function [ Experiment, snapshotExperimentPath ] = saveExpDefForRun( this, ExperimentStruct, snapshotDir )
import experiments.internal.*;

snapshotExperimentPath = fullfile( snapshotDir, [ ExperimentStruct.Name, '.mat' ] );

ExperimentStruct = JSProjectService.updateExpDefForClone( ExperimentStruct );
Experiment = experiments.internal.Experiment.fromStruct( ExperimentStruct, snapshotExperimentPath );

projectPath = this.getCurrentProjectPath(  );
save( snapshotExperimentPath, 'Experiment' );

snapshotExperimentPath = extractAfter( snapshotExperimentPath, strlength( projectPath ) + 1 );
status = fileattrib( fullfile( this.getCurrentProjectPath(  ), snapshotExperimentPath ), '-w' );
assert( status > 0, 'Failed to set file as read-only' );
end 

function [ snapshotDir, snapshotFiles ] = createSnapshotFolderAndCopyDependencies( this, runID, expDef )

snapshotDir = fullfile( this.getRunDir( runID ), 'Snapshot' );
if ~exist( snapshotDir, 'dir' )
mkdir( snapshotDir );
end 
snapshotFiles = string.empty(  );

isCustomExperiment = strcmp( expDef.Process.Type, 'CustomTraining' );
if ~isCustomExperiment
snapshotFiles = this.dependencyAnalysis( expDef.Process.SetupFcn, snapshotDir, snapshotFiles );

for n = 1:length( expDef.Process.Metrics )
metricCellArray = expDef.Process.Metrics( n );
snapshotFiles = this.dependencyAnalysis( metricCellArray{ 1 }{ 1 }, snapshotDir, snapshotFiles );
end 
else 
snapshotFiles = this.dependencyAnalysis( expDef.Process.TrainingFcn, snapshotDir, snapshotFiles );
end 
if ~isempty( expDef.BayesOptOptions ) && isfield( expDef.BayesOptOptions, 'XConstraintFcn' )
snapshotFiles = this.dependencyAnalysis( expDef.BayesOptOptions.XConstraintFcn, snapshotDir, snapshotFiles );
snapshotFiles = this.dependencyAnalysis( expDef.BayesOptOptions.ConditionalVariableFcn, snapshotDir, snapshotFiles );
end 
end 

function createParallelPoolAndAttachFiles( this, snapshotDir )
if this.parallelToggleOn
w = warning( 'off', 'parallel:lang:pool:IgnoringAlreadyAttachedFiles' );
cleanup = onCleanup( @(  )warning( w ) );
this.poolObj = gcp;
this.updateStopValueOnPool(  - 1 );
addAttachedFiles( this.poolObj, { snapshotDir } );

end 
end 

function snapshotFiles = dependencyAnalysis( this, srcFile, snapshotDir, snapshotFiles )





if ~isempty( which( srcFile ) )
[ fList, ~ ] = matlab.codetools.requiredFilesAndProducts( srcFile );


projectPath = this.getCurrentProjectPath(  );

for file = string( fList )
if file.startsWith( projectPath )
relpath = file.extractAfter( strlength( projectPath ) + 1 );
dest = fullfile( snapshotDir, relpath );
destFolder = fileparts( dest );
if ~exist( destFolder, 'dir' )
mkdir( destFolder );
end 
if ~( ismember( relpath, snapshotFiles ) )
copyfile( file, dest );
status = fileattrib( dest, '-w' );
assert( status > 0, 'Failed to set file as read-only' );
snapshotFiles( end  + 1 ) = relpath;
end 
end 
end 
end 
end 

function values = parseValues( ~, inp )
values = eval( inp{ 2 } );
if ~iscell( values )
values = mat2cell( values, 1, ones( 1, length( values ) ) );
end 
end 

function endOfRun( this, ~, ~ )

runID = this.execInfo.runID;
runInfo = this.rsGetRun( runID );
runInfo.completionTime = experiments.internal.getCurrentTimeString(  );
this.rsSetRun( runInfo );


matlab.ddux.internal.logData( this.usageDataId, "experimentrunid", this.execInfo.runID,  ...
"experimentid", runInfo.expId,  ...
"experimentstarttime", runInfo.startTime,  ...
"experimentendtime", runInfo.completionTime,  ...
"experimentruninparallel", this.parallelToggleOn,  ...
"experimentusedbayesopt", this.execInfo.isBayesOptExp,  ...
"experimentruninbatch", this.execInfo.runBatch,  ...
"experimentnumberoftrials", length( runInfo.data ) );

this.cancelTrials( runID, true );
this.canceledTrials = [  ];
this.isExpRunning = false;
this.stopAndCancel = false;
this.execInfo = [  ];
this.emit( [ 'endRun/', runInfo.uuid,  ], runInfo.completionTime );
this.emit( "endRun" );
end 

function saveTrialParamsAndOutputs( this, trialDir, params, outputs )
import experiments.internal.ExperimentException;
trialInputFile = fullfile( trialDir, 'input.mat' );
try 
paramValues = params;
save( trialInputFile, 'paramValues' );
catch causeME
mex = ExperimentException( message( 'experiments:manager:ErrorSaveTrialInput', trialInputFile ) );
mex = mex.addCause( ExperimentException( causeME ) );
throw( mex );
end 

trialOutputFile = fullfile( trialDir, 'output.mat' );
try 
if isstruct( outputs )
save( trialOutputFile, '-struct', 'outputs' );
else 
save( trialOutputFile, 'outputs' );
end 
catch causeME
mex = ExperimentException( message( 'experiments:manager:ErrorSaveTrialOutput', trialOutputFile ) );
mex = mex.addCause( ExperimentException( causeME ) );
throw( mex );
end 

end 

function saveTrialVisualizationData( this, trialDir, validationData, trainingData )
import experiments.internal.ExperimentException;

if isempty( this.feature.mockTrainNetwork )
trialConfusionMatrixInfoFile = fullfile( trialDir, 'confusionmatrix.mat' );
trialROCCurveInfoFile = fullfile( trialDir, 'roccurve.mat' );


matrixForValidationData = validationData.matrixForValidationData;
truePredictedLabelsForValidation = validationData.truePredictedLabelsForValidation;
falsePositiveRatesArrayForValidation = validationData.falsePositiveRatesArrayForValidation;
truePositiveRatesArrayForValidation = validationData.truePositiveRatesArrayForValidation;
thresholdsArrayForValidation = validationData.thresholdsArrayForValidation;
aucArrayForValidation = validationData.aucArrayForValidation;
orderForValidation = validationData.truePredictedLabelsForValidation;
errorLabelValidation = validationData.errorLabelConfusionMatrixValidation;
errorLabelROCCurveValidation = validationData.errorLabelROCCurveValidation;


matrixForTrainingData = trainingData.matrixForTrainingData;
truePredictedLabelsForTraining = trainingData.truePredictedLabelsForTraining;
falsePositiveRatesArrayForTraining = trainingData.falsePositiveRatesArrayForTraining;
truePositiveRatesArrayForTraining = trainingData.truePositiveRatesArrayForTraining;
thresholdsArrayForTraining = trainingData.thresholdsArrayForTraining;
aucArrayForTraining = trainingData.aucArrayForTraining;
orderForTraining = trainingData.truePredictedLabelsForTraining;
errorLabel = trainingData.errorLabelConfusionMatrix;
errorLabelROCCurve = trainingData.errorLabelROCCurve;

try 



version = 2;
save( trialConfusionMatrixInfoFile, 'matrixForTrainingData', 'truePredictedLabelsForTraining', 'errorLabel',  ...
'matrixForValidationData', 'truePredictedLabelsForValidation', 'errorLabelValidation', 'version' );
catch causeME
mex = ExperimentException( message( 'experiments:manager:ErrorSaveTrialConfusionMatrix', trialConfusionMatrixInfoFile ) );
mex = mex.addCause( ExperimentException( causeME ) );
throw( mex );
end 
try 

if this.feature.showROCCurve
save( trialROCCurveInfoFile, 'falsePositiveRatesArrayForTraining', 'truePositiveRatesArrayForTraining', 'thresholdsArrayForTraining', 'aucArrayForTraining', 'orderForTraining', 'errorLabelROCCurve',  ...
'falsePositiveRatesArrayForValidation', 'truePositiveRatesArrayForValidation', 'thresholdsArrayForValidation', 'aucArrayForValidation', 'orderForValidation', 'errorLabelROCCurveValidation' );
end 
catch causeME
mex = ExperimentException( message( 'experiments:manager:ErrorSaveTrialROCCurve', trialROCCurveInfoFile ) );
mex = mex.addCause( ExperimentException( causeME ) );
throw( mex );
end 
end 
end 

function runTrialPreProcessing( this )
for trialID = this.execInfo.trialID
this.preProcessTrial( trialID );
end 
end 

function runBayesoptTrialPreProcessing( this )
trialID = this.execInfo.trialID( end  );
this.preProcessTrial( trialID );
end 

function preProcessTrial( this, trialID )
runID = this.execInfo.runID;
trialDir = fullfile( this.getRunDir( runID ), [ 'Trial_', num2str( trialID ) ] );
if ~exist( trialDir, 'dir' )
mkdir( trialDir );
end 

outputFile = fullfile( trialDir, 'output.mat' );
confusionMatrixFile = fullfile( trialDir, 'confusionmatrix.mat' );
rocCurveFile = fullfile( trialDir, 'roccurve.mat' );



if ( isfile( outputFile ) ) && isempty( this.feature.mockTrainNetwork )
delete( outputFile );
end 
if ( isfile( confusionMatrixFile ) ) && isempty( this.feature.mockTrainNetwork )
delete( confusionMatrixFile );
end 
if ( isfile( rocCurveFile ) ) && isempty( this.feature.mockTrainNetwork )
delete( rocCurveFile );
end 
end 


function runBayesOptTrials( this )
optVars = this.execInfo.optVars;
runID = this.execInfo.runID;
bayesOptOptions = this.execInfo.BayesOptOptions;

if ~isempty( bayesOptOptions.XConstraintFcn )
bayesOptOptions.XConstraintFcn = str2func( bayesOptOptions.XConstraintFcn );
end 
if ~isempty( bayesOptOptions.ConditionalVariableFcn )
bayesOptOptions.ConditionalVariableFcn = str2func( bayesOptOptions.ConditionalVariableFcn );
end 
this.currentTrial.runID = runID;

if ~this.parallelToggleOn
cleanupObj3 = onCleanup( @(  )this.endOfRun(  ) );
bayesopt( @this.trainingFunction, optVars, 'Verbose', 0,  ...
'AcquisitionFunctionName', bayesOptOptions.AcquisitionFunctionName, 'PlotFcn', [  ],  ...
'OutputFcn', @this.handleBayesOptStop,  ...
'MaxObjectiveEvaluations', str2num( bayesOptOptions.MaxTrials ),  ...
'MaxTime', bayesOptOptions.MaxExecutionTime,  ...
'XConstraintFcn', bayesOptOptions.XConstraintFcn,  ...
'ConditionalVariableFcn', bayesOptOptions.ConditionalVariableFcn );
else 
cleanupObj3 = onCleanup( @(  )this.endOfRun_parallel(  ) );
dq = this.dataQueue;
bayesopt( @( optVars )experiments.internal.bayesoptRunTrial( dq, optVars ), optVars, 'Verbose', 0,  ...
'AcquisitionFunctionName', bayesOptOptions.AcquisitionFunctionName, 'PlotFcn', [  ],  ...
'OutputFcn', @this.handleBayesOptStop,  ...
'UseParallel', true,  ...
'MaxObjectiveEvaluations', str2num( bayesOptOptions.MaxTrials ),  ...
'MaxTime', bayesOptOptions.MaxExecutionTime,  ...
'XConstraintFcn', bayesOptOptions.XConstraintFcn,  ...
'ConditionalVariableFcn', bayesOptOptions.ConditionalVariableFcn );
end 
end 

function setTrialID( this, trialID )
this.execInfo.trialID = trialID;
end 

function [ bayesObj, constraints, trialID ] = trainingFunction( this, optVars )

trialID = this.execInfo.trialID;
constraints = [  ];
incrementTrialID = onCleanup( @(  )this.setTrialID( trialID + 1 ) );
runID = this.execInfo.runID;
run = this.rsGetRun( runID );
setupFcn = this.execInfo.setupFcn;
trainingFcn = this.execInfo.trainingFcn;
trainingType = this.execInfo.trainingType;
usesValidation = this.execInfo.usesValidation;
optimizableMetricData = this.execInfo.OptimizableMetricData;


oldState = rng(  );
rng( run.RNGState );
cleanupRNG = onCleanup( @(  )rng( oldState ) );

this.runBayesoptTrialPreProcessing(  );

paramStruct = table2struct( optVars );
params = struct2cell( paramStruct );
paramList = fieldnames( paramStruct );


for j = 1:length( paramList )
colName = [ 'Col_Input_', paramList{ j } ];
run.colValues.( colName ) = sort( [ run.colValues.( colName ), params{ j } ] );


if ( iscategorical( paramStruct.( paramList{ j } ) ) )
paramStruct.( paramList{ j } ) = string( paramStruct.( paramList{ j } ) );
end 
end 

columnValues = this.rsSerializeNansInfinitys( run.colValues );
this.emit( [ 'updateColumnValues/', run.uuid ], columnValues );

run.data{ trialID, 1 } = this.createTrialRow( trialID, params' );
this.rsSetRun( run );
curTrial = run.data{ trialID };
this.currentTrial.trialID = trialID;

try 
if strcmp( this.execInfo.trainingType, 'CustomTraining' )
bayesObj = this.runCurrentTrial_custom( curTrial, trialID, runID, trainingFcn, paramList, paramStruct );
curTrial = this.rsGetRun( runID ).data{ trialID };
if strcmp( curTrial{ 2 }.status, 'Canceled' )
bayesObj = NaN;
return ;
elseif strcmp( curTrial{ 2 }.status, 'Error' )
error( curTrial{ 2 }.errorText );
end 
else 
this.runCurrentBayesOptTrial( curTrial, trialID,  ...
runID,  ...
setupFcn,  ...
trainingFcn,  ...
paramStruct,  ...
paramList,  ...
trainingType,  ...
usesValidation );
curTrial = this.rsGetRun( runID ).data{ trialID };
if strcmp( curTrial{ 2 }.status, 'Canceled' )
bayesObj = NaN;
return ;
elseif strcmp( curTrial{ 2 }.status, 'Error' )
error( curTrial{ 2 }.errorText );
end 
optMtrx = optimizableMetricData( 1 );




stdMetric_indx = 4 + length( paramList );
bayesObj = curTrial{ optMtrx{ 1 } + stdMetric_indx };
isMinimize = optimizableMetricData( 2 );



if ( isstruct( bayesObj ) )
bayesObj = str2double( bayesObj.value );
end 
if strcmp( isMinimize{ 1 }, 'Maximize' )
bayesObj =  - bayesObj;
end 
end 
catch ME

ME = experiments.internal.ExperimentException( ME );
curTrial = this.rsGetRun( runID ).data{ trialID };
curTrial{ 2 }.status = 'Error';
curTrial{ 2 }.errorText = this.getErrorReport( ME );
curTrial{ 3 }.completionTime = experiments.internal.getCurrentTimeString(  );

res.rowData = curTrial;
res.rowInd = trialID - 1;
run = this.rsGetRun( runID );
this.rsUpdateTrial( runID, trialID, res.rowData );
this.emit( [ 'updateRow/', run.uuid ], res );
bayesObj = NaN;
return ;
end 
end 

function result = runCurrentBayesOptTrial( this, curTrial, trialID, runID, setupFcn, trainingFcn, paramStruct, paramList, trainingType, usesValidation )
run = this.rsGetRun( runID );
execInfoObj = this.execInfo;
execInfoObj.lastProgressTime = tic;
execInfoObj.runID = runID;
execInfoObj.trialID = trialID;
label = message( 'experiments:results:TrainingPlotLabel' ).getString(  );
title = message( 'experiments:results:VisualizationLabel', label, trialID, run.runLabel, run.expName ).getString(  );
execInfoObj.trainingPlotTitle = title;


trialRunner = this.createTrialRunner( paramStruct, trialID, runID, setupFcn, trainingFcn, trainingType );
this.addPlotUpdateListener( runID, trialID, trialRunner );
trialRunner.msgFunction = @this.handleWorkerData;
trialRunner.stopFunction = @this.shouldStopTraining;
this.execInfo.trialRunner = trialRunner;
result = trialRunner.runTrialInParallel( this.feature.mockTrainNetwork );
end 

function stop = handleBayesOptStop( this, results, ~ )
runID = this.execInfo.runID;
run = this.rsGetRun( runID );

n = length( run.data );
for i = 1:n
if strcmp( run.data{ i }{ 2 }.status, 'Error' )
stop = true;
return ;
end 
end 
if ~isempty( results.IndexOfMinimumTrace )
iteration = results.IndexOfMinimumTrace( end  );
if ~isnan( iteration )
assert( length( results.UserDataTrace ) >= iteration );
indxOfBest = results.UserDataTrace{ iteration };
run.indexOfBestFromBayesopt = indxOfBest;
this.rsSetRun( run );
this.emit( [ 'updateBestSoFar/', run.uuid ], indxOfBest );
end 
end 
stop = ~this.isExpRunning;

end 

function setEndOfLoopAndCallEndOfRun( this )
this.endOfLoop = true;
if ( isempty( this.trialRunnerMap ) )
this.endOfRun_parallel(  );
end 
end 



function runTrials( this )

runID = this.execInfo.runID;
trainingType = this.execInfo.trainingType;
usesValidation = this.execInfo.usesValidation;
setupFcn = this.execInfo.setupFcn;
trainingFcn = this.execInfo.trainingFcn;

run = this.rsGetRun( runID ).data;

paramList = this.rsGetRun( runID ).paramList;

if ~this.parallelToggleOn
cleanupObj3 = onCleanup( @(  )this.endOfRun(  ) );
else 
cleanupObj3 = onCleanup( @(  )this.setEndOfLoopAndCallEndOfRun(  ) );
end 

this.currentTrial.runID = runID;

this.isPostProcessingDone = [  ];
this.runTrialPreProcessing(  );

for index = 1:length( this.execInfo.trialID )

trialID = this.execInfo.trialID( index );

if any( this.canceledTrials == trialID )
continue ;
end 



if this.isExpRunning == false


break ;
end 

this.currentTrial.trialID = trialID;
curTrial = run{ trialID };
try 
if this.parallelToggleOn == false
if ~isempty( setupFcn )
res = this.runCurrentTrial( curTrial,  ...
trialID,  ...
runID,  ...
setupFcn,  ...
paramList,  ...
trainingType,  ...
usesValidation );
else 
this.runCurrentTrial_custom( curTrial,  ...
trialID,  ...
runID,  ...
trainingFcn,  ...
paramList,  ...
[  ] );
end 
else 

res = this.runCurrentTrial_parallel( curTrial,  ...
trialID,  ...
runID,  ...
setupFcn,  ...
trainingFcn,  ...
paramList,  ...
trainingType );
end 
catch ME

ME = experiments.internal.ExperimentException( ME );
runData = this.rsGetRun( runID );
curTrial = runData.data{ trialID };
curTrial{ 2 }.status = 'Error';
curTrial{ 2 }.errorText = this.getErrorReport( ME );
curTrial{ 3 }.completionTime = experiments.internal.getCurrentTimeString(  );
res.rowData = curTrial;
res.rowInd = trialID - 1;
this.rsUpdateTrial( runID, trialID, res.rowData );
this.emit( [ 'updateRow/', runData.uuid ], res );
end 
end 
end 

function endOfRun_parallel( this )
isBayesOptExp = this.execInfo.isBayesOptExp;
if isBayesOptExp && ~isempty( this.trialRunnerMap )







trialRunnerKeys = keys( this.trialRunnerMap );
runData = this.rsGetRun( this.execInfo.runID ).data;
for i = 1:length( trialRunnerKeys )
trialID = trialRunnerKeys{ i };
trialData = runData{ trialID };
trialData{ 2 } = struct( 'status', 'Canceled', 'text', '', 'errorText', '', 'progressPercent', 0 );
res.rowInd = trialID - 1;
res.rowData = trialData;
sendData.res = res;
sendData.trialID = trialID;
sendData.runID = this.execInfo.runID;
this.handleWorkerData( { 'saveAndCleanupTrialRunner',  ...
this.execInfo.runID, trialID, sendData } );
end 

end 
assert( isempty( this.trialRunnerMap ) );
this.endOfRun(  );
this.updateStopValueOnPool( [  ] );
this.futureTrialInfoMap = containers.Map( 'KeyType', 'double', 'ValueType', 'any' );
this.stopDataQueueMap = containers.Map( 'KeyType', 'double', 'ValueType', 'any' );
this.completedWorker = containers.Map( 'KeyType', 'double', 'ValueType', 'any' );
this.afterEachFuture = parallel.FevalFuture.empty;
this.isPostProcessingDone = [  ];
this.poolObj = [  ];
this.endOfLoop = false;
end 

function paramStruct = constructParamStruct( ~, paramList, paramValues )
paramStruct = struct(  );
paramList = string( paramList );
if ~isempty( paramList )
paramStruct = cell2struct( paramValues', paramList.cellstr(  ), 1 );
end 
end 

function result = runCurrentTrial_custom( this, curTrial, trialID, runID, trainingFcn, paramList, paramStruct )
run = this.rsGetRun( runID );
execInfoObj = this.execInfo;
execInfoObj.lastProgressTime = tic;
execInfoObj.runID = runID;
execInfoObj.trialID = trialID;
label = message( 'experiments:results:TrainingPlotLabel' ).getString(  );
title = message( 'experiments:results:VisualizationLabel', label, trialID, run.runLabel, run.expName ).getString(  );
execInfoObj.trainingPlotTitle = title;

snapshotDir = fullfile( this.getRunDir( runID ), 'Snapshot' );
if isempty( paramStruct )
paramStruct = this.constructParamStruct( paramList, curTrial( 4:3 + length( paramList ) ) );
end 
trialRunner = experiments.internal.CustomTrialRunner( [  ],  ...
execInfoObj,  ...
run.RNGState,  ...
paramStruct,  ...
snapshotDir,  ...
trainingFcn );
this.addPlotUpdateListener( runID, trialID, trialRunner );
trialRunner.msgFunction = @this.handleWorkerData;
trialRunner.stopFunction = @this.shouldStopTraining;
this.execInfo.trialRunner = trialRunner;
trialDir = fullfile( this.getRunDir( runID ), [ 'Trial_', num2str( trialID ) ] );
result = trialRunner.runTrialInParallel( trialDir );
end 

function result = runCurrentTrial( this, curTrial, trialID, runID, setupFcn, paramList, trainingType, usesValidation )
run = this.rsGetRun( runID );
execInfoObj = this.execInfo;
execInfoObj.lastProgressTime = tic;
execInfoObj.runID = runID;
execInfoObj.trialID = trialID;
label = message( 'experiments:results:TrainingPlotLabel' ).getString(  );
title = message( 'experiments:results:VisualizationLabel', label, trialID, run.runLabel, run.expName ).getString(  );
execInfoObj.trainingPlotTitle = title;

paramStruct = this.constructParamStruct( paramList, curTrial( 4:3 + length( paramList ) ) );
trainingFcn = '';
trialRunner = this.createTrialRunner( paramStruct, trialID, runID, setupFcn, trainingFcn, trainingType );
this.addPlotUpdateListener( runID, trialID, trialRunner );
trialRunner.msgFunction = @this.handleWorkerData;
trialRunner.stopFunction = @this.shouldStopTraining;
this.execInfo.trialRunner = trialRunner;
result = trialRunner.runTrialInParallel( this.feature.mockTrainNetwork );
end 

function res = runCurrentTrial_parallel( this, curTrial, trialID, runID, setupFcn, trainingFcn, paramList, trainingType )
res.rowInd = trialID - 1;
res.rowData = curTrial;
paramStruct = this.constructParamStruct( paramList, curTrial( 4:3 + length( paramList ) ) );
trialRunner = this.createTrialRunner( paramStruct, trialID, runID, setupFcn, trainingFcn, trainingType );







futureTrialInfo = parfeval( this.poolObj, @trialRunner.runTrialInParallel, 1, this.feature.mockTrainNetwork );
this.futureTrialInfoMap( trialID ) = struct( 'trialID', trialID, 'futureTrialInfo', futureTrialInfo );

if ~this.isExpRunning || ismember( trialID, this.canceledTrials )
futureTrialInfo.cancel;

if ~isKey( this.completedWorker, trialID )
this.cancelTrial( trialID );
end 
else 






this.afterEachFuture( end  + 1 ) = afterEach( futureTrialInfo, @( futureTrialInfo )this.parallelPostProcessing( runID, trialID, futureTrialInfo ), 0, 'PassFuture', true );
end 
end 

function parallelPostProcessing( this, runID, trialID, futureTrialInfo )



if futureTrialInfo.State == "failed"
send( this.dataQueue, { 'handleFailedTrial', runID, trialID, futureTrialInfo } );
end 

end 

function trialRunner = createTrialRunner( this, paramStruct, trialID, runID, setupFcn, trainingFcn, trainingType )
run = this.rsGetRun( runID );
curRowData = run.data{ trialID };
execInfoObj = this.execInfo;
execInfoObj.lastProgressTime = tic;
currentTrial_parallel = struct( 'runID', runID, 'trialID', trialID );
snapshotDir = this.execInfo.snapshotDir;
metrics = run.Metrics;

if isempty( trainingFcn )
dq = [  ];
if this.parallelToggleOn
dq = this.dataQueue;
end 
execInfoObj.showROCCurve = this.feature.showROCCurve;
trialRunner = experiments.internal.TrialRunner( run.runLabel, run.expName,  ...
run.RNGState, paramStruct,  ...
setupFcn, execInfoObj, currentTrial_parallel,  ...
curRowData, dq, snapshotDir,  ...
metrics, trainingType );
else 
execInfoObj.runID = runID;
execInfoObj.trialID = trialID;
label = message( 'experiments:results:TrainingPlotLabel' ).getString(  );
title = message( 'experiments:results:VisualizationLabel', label, trialID, run.runLabel, run.expName ).getString(  );
execInfoObj.trainingPlotTitle = title;
trialRunner = experiments.internal.CustomTrialRunner( this.dataQueue,  ...
execInfoObj,  ...
run.RNGState,  ...
paramStruct,  ...
snapshotDir,  ...
trainingFcn );
end 
this.addPlotUpdateListener( runID, trialID, trialRunner );
if this.parallelToggleOn
this.trialRunnerMap( trialID ) = trialRunner;
end 
end 

function trialRunner = createTrialRunnerForBayesopt( this, paramStruct )
runID = this.execInfo.runID;
trialID = this.execInfo.trialID( end  );
run = this.rsGetRun( this.execInfo.runID );
this.runBayesoptTrialPreProcessing(  );

params = struct2cell( paramStruct );
paramList = fieldnames( paramStruct );


for j = 1:length( paramList )
colName = [ 'Col_Input_', paramList{ j } ];
run.colValues.( colName ) = sort( [ run.colValues.( colName ), params{ j } ] );
if ( iscategorical( paramStruct.( paramList{ j } ) ) )
paramStruct.( paramList{ j } ) = string( paramStruct.( paramList{ j } ) );
end 
end 

columnValues = this.rsSerializeNansInfinitys( run.colValues );
this.emit( [ 'updateColumnValues/', run.uuid ], columnValues );

run.data{ trialID, 1 } = this.createTrialRow( trialID, params' );
this.rsSetRun( run );
curTrial = run.data{ trialID };
this.currentTrial.trialID = trialID;

res.rowInd = trialID - 1;
res.rowData = this.rsUpdateTrial( runID, trialID, curTrial );
this.emit( [ 'updateRow/', run.uuid ], res );

trialRunner = this.createTrialRunner( paramStruct,  ...
trialID,  ...
runID,  ...
this.execInfo.setupFcn,  ...
this.execInfo.trainingFcn,  ...
this.execInfo.trainingType );

this.execInfo.trialID = [ this.execInfo.trialID, trialID + 1 ];
end 

function trRunner = getTrialRunner( this, trialID )
if this.parallelToggleOn
trRunner = this.trialRunnerMap( trialID );
else 
trRunner = this.execInfo.trialRunner;
end 
end 

function createColumns( this, runID, infoNames, metricNames )
run = this.rsGetRun( runID );
shouldEmit = false;
index = length( run.data{ 1 } );

numCol = length( infoNames );
type = '';
propName = 'Info';
indexMap = [ propName, 'Name2IndexMap' ];
for i = 1:numCol
curItem = char( infoNames( i ) );
if ~this.execInfo.( indexMap ).isKey( curItem )
run.( propName )( end  + 1 ) = struct( 'name', curItem, 'type', type, 'index', index );
run.data = cellfun( @( x )[ x( : )', { struct( 'value', 0, 'error', '', 'state', 'NA' ) } ], run.data, 'UniformOutput', false );
run.colValues.( [ 'Col_', propName, '_', curItem ] ) = [  ];
index = index + 1;
this.execInfo.( indexMap )( curItem ) = index;
shouldEmit = true;
end 
end 

numCol = length( metricNames );
type = 'number';
propName = 'Metrics';
indexMap = [ propName, 'Name2IndexMap' ];
for i = 1:numCol
curItem = char( metricNames( i ) );
if ~this.execInfo.( indexMap ).isKey( curItem )
run.( propName )( end  + 1 ) = struct( 'name', curItem, 'type', type, 'index', index );
run.data = cellfun( @( x )[ x( : )', { struct( 'value', 0, 'error', '', 'state', 'NA' ) } ], run.data, 'UniformOutput', false );
run.colValues.( [ 'Col_', propName, '_', curItem ] ) = [  ];
index = index + 1;
this.execInfo.( indexMap )( curItem ) = index;
shouldEmit = true;
end 
end 

if shouldEmit
cleanupSaveResults = this.suspendSaveResult(  );
this.rsSetRun( run );
this.emit( [ 'addCol/', run.uuid ], run );
end 
end 

function updateCusExpResult( this, runID, trialID, msg )
data = cellfun( @( x )convertCharsToStrings( x ), this.rsGetTrial( runID, trialID ), 'UniformOutput', false );
shouldEmit = false;
switch ( msg.ID )
case 'Progress'
data{ 2 }.progressPercent = msg.progressPercent;
shouldEmit = true;
case 'Running'
data{ 2 }.status = 'Running';
data{ 3 } = msg.trialStartTime;
shouldEmit = true;
case 'UserStatus'
data{ 2 }.userStatus = msg.status;
shouldEmit = true;
case { 'Error', 'Stopped', 'Complete', 'Canceled' }
data{ 2 }.status = msg.ID;
if strcmp( msg.ID, 'Complete' )
data{ 2 }.progressPercent = 100;
data{ 2 }.resultInCluster = this.execInfo.runBatch;
end 
if strcmp( msg.ID, 'Error' )
data{ 2 }.errorText = msg.errorText;
end 
sendData.runID = runID;
sendData.trialID = trialID;
if isfield( msg, 'paramList' )
sendData.paramList = msg.paramList;
end 
if isfield( msg, 'output' )
sendData.output = msg.output;
end 
res.rowInd = trialID - 1;
res.rowData = data;
sendData.res = res;
this.handleWorkerData( { 'saveAndCleanupTrialRunner',  ...
runID, trialID, sendData } );
end 
if shouldEmit
res.rowInd = trialID - 1;
res.rowData = this.rsUpdateTrial( runID, trialID, data );
run = this.rsGetRun( runID );
this.emit( [ 'updateRow/', run.uuid ], res );
end 
end 

function updateColumns( this, runID, trialID, val, propName )
run = this.rsGetRun( runID );
data = run.data{ trialID };
f = fieldnames( val );
map = [ propName, 'Name2IndexMap' ];
for i = 1:length( f )
name = f{ i };
ind = this.execInfo.( map )( name );
data{ ind } = val.( name );
end 
callSetRun = false;
for i = 1:length( run.Info )
indx = run.Info( i ).index + 1;
if ~isstruct( data{ indx } ) && isempty( run.Info( i ).type )
if ischar( data{ indx } ) || islogical( data{ indx } )
run.Info( i ).type = 'string';
else 
run.Info( i ).type = 'number';
end 
callSetRun = true;
end 
end 
if callSetRun
cleanupSaveResults = this.suspendSaveResult(  );
this.rsSetRun( run );
end 
res.rowInd = trialID - 1;
res.rowData = this.rsUpdateTrial( runID, trialID, data );
this.emit( [ 'updateRow/', run.uuid ], res );

end 

function handleWorkerData( this, data )
action = data{ 1 };
switch ( action )
case 'MessageQue'
[ runID, trialID, msg ] = deal( data{ 2:end  } );
if ~this.isExpRunning || ismember( trialID, this.canceledTrials )
trial = this.rsGetRun( runID ).data{ trialID };
if trial{ 2 }.status ~= "Running"

return ;
end 
end 
trRunner = this.getTrialRunner( trialID );
trRunner.initPlot(  );
if ~isempty( msg.newInfo ) || ~isempty( msg.newMetrics )
this.createColumns( runID, msg.newInfo, msg.newMetrics );
end 
if ~isempty( msg.newMetrics )
trRunner.Metrics = msg.newMetrics;
trRunner.addMetrics(  );
end 
if isfield( msg, 'Progress' )
this.updateCusExpResult( runID, trialID,  ...
struct( 'ID', 'Progress', 'progressPercent', msg.Progress ) );
end 
if isfield( msg, 'UserStatus' )
this.updateCusExpResult( runID, trialID,  ...
struct( 'ID', 'UserStatus', 'status', msg.UserStatus ) );
end 

if isfield( msg, 'XLabel' )
trRunner.XLabel = msg.XLabel;
trRunner.updateXLabel(  );
end 
for i = 1:length( msg.subPlots )
trRunner.LabelMap( char( msg.subPlots{ i }{ 1 } ) ) =  ...
msg.subPlots{ i }{ 2 };
trRunner.groupPlots(  );
end 
if ~isempty( fieldnames( msg.InfoValue ) )
this.updateColumns( runID, trialID, msg.InfoValue, 'Info' );
end 
if ~isempty( fieldnames( msg.MetricsValue ) )
this.updateColumns( runID, trialID, msg.MetricsValue, 'Metrics' );
trRunner.updatePlot( msg.PlotValue );
end 
this.updateRunInfoTask( runID );
case 'UpdateResult'
[ runID, trialID, result ] = deal( data{ 2:end  } );
assert( ismember( result.ID, [ "Running", "Stopped", "Complete", "Error", "Canceled" ] ) )
if result.ID ~= "Running"
this.updateCusExpResult( runID, trialID, result );
this.updateRunInfoTask( runID );
return ;
end 
if ~this.isExpRunning || ismember( trialID, this.canceledTrials )
return ;
end 
this.updateCusExpResult( runID, trialID, result );
this.updateRunInfoTask( runID );
case 'savetodisk'
[ runID, trialID, res ] = deal( data{ 2:end  } );
assert( res.rowData{ 2 }.status == "Running", "The trial status from parallel worker should be running" );


if ~this.isExpRunning || ismember( trialID, this.canceledTrials )
return ;
end 
res.rowData = this.rsUpdateTrial( runID, trialID, res.rowData );
this.emit( [ 'updateRow/', this.rsGetRun( runID ).uuid ], res );
case 'emittotable'
[ runID, trialID, res ] = deal( data{ 2:end  } );
assert( res.rowData{ 2 }.status == "Running", "The trial status from parallel worker should be running" );


if ~this.isExpRunning || ismember( trialID, this.canceledTrials )
return ;
end 
this.updateTrialDataOnRunInfoTask( runID, trialID, res.rowData );
this.emit( [ 'updateRow/', this.rsGetRun( runID ).uuid ], res );
case 'stopDataQueue'
[ ~, trialID, stopDataQueue ] = deal( data{ 2:end  } );



this.stopDataQueueMap( trialID ) = stopDataQueue;
if ( ~this.isExpRunning || ismember( trialID, this.canceledTrials ) )
send( stopDataQueue, {  } );
end 
case 'updateMetricsConfig'
[ runID, ~, res ] = deal( data{ 2:end  } );
run = this.rsGetRun( runID );
run.Metrics = res;
this.rsSetRun( run );
case 'createTrialRunnerForBayesopt'
[ paramStruct, replyQueue ] = deal( data{ 2:end  } );
trialRunner = this.createTrialRunnerForBayesopt( paramStruct );
send( replyQueue, trialRunner );
case 'saveAndCleanupTrialRunner'
[ ~, trialID, saveData ] = deal( data{ 2:end  } );
if isempty( this.execInfo )

return 
end 
if this.parallelToggleOn
if ~this.execInfo.isBayesOptExp




futureObj = this.futureTrialInfoMap( trialID ).futureTrialInfo;
if ( futureObj.State == "finished" && ~isempty( futureObj.Error ) &&  ...
futureObj.Error.identifier == "parallel:fevalqueue:ExecutionCancelled" ) ||  ...
( futureObj.State == "failed" )
return ;
end 
end 
this.completedWorker( trialID ) = true;
this.saveAndCleanUpParallel( saveData );
else 
this.saveAndCleanUpParallel( saveData );
end 
case 'handleFailedTrial'
[ runID, trialID, futureTrialInfo ] = deal( data{ 2:end  } );
if ~isKey( this.completedWorker, trialID )
this.completedWorker( trialID ) = true;
import experiments.internal.ExperimentException;
ME = ExperimentException( message( futureTrialInfo.Error.identifier ) );
curTrial = this.rsGetRun( runID ).data{ trialID };
curTrial{ 2 }.status = 'Error';
curTrial{ 2 }.errorText = this.getErrorReport( ME );
curTrial{ 3 }.completionTime = experiments.internal.getCurrentTimeString(  );
res.rowData = curTrial;
res.rowInd = trialID - 1;
this.rsUpdateTrial( runID, trialID, res.rowData );
sendData.runID = runID;
sendData.trialID = trialID;
sendData.paramList = '';
sendData.res = res;
this.saveAndCleanUpParallel( sendData );
end 
end 
end 

function saveTrainingPlots( this, trialID, trialDir )

trainingAxes = this.getTrainingAxes( trialID );
if ~isempty( trainingAxes.Parent )


savefig( trainingAxes.Parent, [ trialDir, filesep, 'trainingPlot.fig' ] );




if isempty( trainingAxes.Parent )

this.setVisualizationAutoDelete(  );
end 
end 

if isempty( trainingAxes.Parent )

trainingPlot = uifigure( 'Visible', 'off' );
cleanupTrainingPlot = onCleanup( @(  )delete( trainingPlot ) );
trainingAxes.Parent = trainingPlot;
savefig( trainingPlot, [ trialDir, filesep, 'trainingPlot.fig' ] );
clear cleanupTrainingPlot;
end 
end 

function trainingAxes = getTrainingAxes( this, trialID )
if this.parallelToggleOn
trialRunnerObj = this.trialRunnerMap( trialID );
trainingAxes = trialRunnerObj.detachTrainingAxes(  );
else 

trialRunnerObj = this.execInfo.trialRunner;
trainingAxes = trialRunnerObj.detachTrainingAxes(  );
end 
end 



function curTrial = saveAndCleanUpParallel( this, data )

trialIDStr = num2str( data.trialID );
trialDir = fullfile( this.getRunDir( data.runID ), [ 'Trial_', trialIDStr ] );
curTrial = data.res.rowData;

if this.execInfo.runBatch
j2ID = this.rsGetRun( data.runID ).job.ID( 2 );
else 
j2ID =  - 1;
end 


paramList = this.rsGetRun( data.runID ).paramList;
if ~ismember( data.res.rowData{ 2 }.status, [ "Error", "Canceled" ] )
paramStruct = this.constructParamStruct( paramList, curTrial( 4:3 + length( data.paramList ) ) );
if this.execInfo.isCustomExp
output = data.output;
else 
output = struct( 'trInfo', data.trInfo, 'nnet', data.nnet );
end 
if this.execInfo.runBatch
this.updateJobStore( [ 'InputOutput_', trialIDStr ], { paramStruct, output }, j2ID );
this.updateJobStore( [ 'TrainingPlot_', trialIDStr ], this.getTrainingAxes( data.trialID ), j2ID );
else 
this.saveTrialParamsAndOutputs( trialDir, paramStruct, output );
this.saveTrainingPlots( data.trialID, trialDir );
end 

if ~this.execInfo.isCustomExp && this.execInfo.runBatch
this.updateJobStore( [ 'VisData_', trialIDStr ], { data.validationData, data.trainingData }, j2ID );
elseif ~this.execInfo.isCustomExp
this.saveTrialVisualizationData( trialDir,  ...
data.validationData,  ...
data.trainingData );
end 
end 



isError = data.res.rowData{ 2 }.status == "Error";
if isError && this.execInfo.isCustomExp && this.execInfo.runBatch
this.updateJobStore( [ 'TrainingPlot_', trialIDStr ], this.getTrainingAxes( data.trialID ), j2ID );
elseif isError && this.execInfo.isCustomExp
this.saveTrainingPlots( data.trialID, trialDir );
end 

status = data.res.rowData{ 2 }.status;
if ~strcmp( status, "Canceled" )

curTrial{ 3 }.completionTime = experiments.internal.getCurrentTimeString(  );
else 
indx = 4 + length( paramList );
curTrial = this.setCancelTrial( curTrial, indx );
end 

res = data.res;
res.rowData = this.rsUpdateTrial( data.runID, data.trialID, curTrial );
run = this.rsGetRun( data.runID );
this.emit( [ 'updateRow/', run.uuid ], res );
if ~this.parallelToggleOn
delete( this.execInfo.trialRunner );
return ;
end 
if isKey( this.trialRunnerMap, data.trialID )
trialRunner = this.trialRunnerMap( data.trialID );
remove( this.trialRunnerMap, data.trialID );
delete( trialRunner );
end 

if ( ~this.execInfo.isBayesOptExp ) && ( isempty( this.trialRunnerMap ) ) && ( this.endOfLoop )
this.endOfRun_parallel(  );
end 

end 

function curTrialNew = setCancelTrial( this, curTrialOld, indx )
curTrialNew = curTrialOld;
curTrialNew{ 2 } = struct( 'status', 'Canceled', 'text', '', 'errorText', '', 'progressPercent', 0 );
if this.execInfo.isBayesOptExp
curTrialNew{ 3 }.completionTime = experiments.internal.getCurrentTimeString(  );
else 
curTrialNew{ 3 }.startTime = '';
curTrialNew{ 3 }.completionTime = '';
end 

for i = indx:length( curTrialNew )
curTrialNew{ i } = struct( 'value', 0, 'error', '', 'state', 'NA' );
end 
end 

function startExecution( this )
this.isExpRunning = true;
runID = this.execInfo.runID;
this.emit( "startRun", runID );
run = this.rsGetRun( runID );
this.emit( [ 'startRun/', run.uuid ] );
if ~this.execInfo.isBayesOptExp
this.runTrials(  );
else 
this.runBayesOptTrials(  );
end 
end 

function colValues = genOutputColValues( ~, runInfo )
if strcmp( runInfo.trainingType, 'classification' )
colValues.Col_TrainingAccuracy = [  ];
else 
colValues.Col_TrainingRMSE = [  ];
end 
colValues.Col_TrainingLoss = [  ];
if runInfo.usesValidation
if strcmp( runInfo.trainingType, 'classification' )
colValues.Col_ValidationAccuracy = [  ];
else 
colValues.Col_ValidationRMSE = [  ];
end 
colValues.Col_ValidationLoss = [  ];
end 
end 

function report = getErrorReport( ~, ME )
report = experiments.internal.getErrorReport( ME, 'ProjectPath', experiments.internal.JSProjectService.getCurrentProjectPath(  ) );
end 

function statusInfo = createStatusInfo( this, status, isCustom )
statusInfo = struct( 'status', status, 'text', '', 'errorText', '', 'progressPercent', 0 );
if ~isCustom
statusInfo.executionEnvironment = struct( 'ExecutionEnvironment', '', 'UseParallel', false );
end 
if ( this.feature.captureWorkerInfo && this.parallelToggleOn )
statusInfo.workerName = '';
end 
end 
end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmplPzg0N.p.
% Please follow local copyright laws when handling this file.

