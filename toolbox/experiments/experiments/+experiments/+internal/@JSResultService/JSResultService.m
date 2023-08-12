classdef JSResultService < handle




properties 
resultInfo
resultsDir
suspendSaveResultCount
end 

events 

AddToProject


RemoveFromProject
end 

methods 

function this = JSResultService(  )
this.reset(  );
this.addlistener( 'CloseProject', @( ~, ~ )this.closeResultService );
this.addlistener( 'OpenProject', @( ~, evtData )this.initResultService( evtData ) );
this.resultsDir = '';
this.suspendSaveResultCount = 0;
end 

function dir = getResultsDir( this )
dir = this.resultsDir;
end 

function cleanup = suspendSaveResult( this )
this.suspendSaveResultCount =  ...
this.suspendSaveResultCount + 1;

function resetSuspendSaveResult( this )
this.suspendSaveResultCount =  ...
this.suspendSaveResultCount - 1;
this.saveResults(  );
end 

cleanup = onCleanup( @(  )resetSuspendSaveResult( this ) );
end 

function [ runID, runLabel ] = getNewRunID( this, expName, expID )


runInfoForExp = this.getRunInfoForExpId( expID );
existingRunLabels = cellfun( @( r )r.runLabel, runInfoForExp, 'UniformOutput', false );
count = this.getNewRunCount( existingRunLabels );

runID = [ expName, '_Result', num2str( count ), '_', datestr( now, 'yyyymmddTHHMMSS' ) ];
runLabel = [ 'Result', num2str( count ) ];
end 

function count = getNewRunCount( ~, existingRunLabels )
count = 1;
while ismember( [ 'Result', num2str( count ) ], existingRunLabels )
count = count + 1;
end 
end 

function cancelTrials( this, runID, emitUpdate, jobState )
R36
this
runID
emitUpdate
jobState = ''
end 
run = this.rsGetRun( runID );
if isfield( run, 'job' )
if isempty( jobState )


return ;
else 
run.job.State = jobState;
this.rsSetRun( run );
end 
end 

runData = run.data;
paramList = run.paramList;
metricStartIndx = 4 + length( paramList );

for trialID = 1:length( runData )
curTrial = runData{ trialID };
if ismember( curTrial{ 2 }.status, { 'Queued', 'Running' } )
if ~exist( 'cleanupSaveResults', 'var' )
cleanupSaveResults = this.suspendSaveResult(  );
end 

if strcmp( curTrial{ 2 }.status, 'Running' )
[ curTrial{ metricStartIndx:end  } ] = deal( struct( 'value', 0, 'error', '', 'state', 'NA' ) );
end 
curTrial{ 2 } = struct( 'status', 'Canceled', 'errorText', '', 'progressPercent', 0 );
trialCompletionTime = struct( 'startTime', '', 'completionTime', '' );
curTrial{ 3 } = trialCompletionTime;

res.rowInd = trialID - 1;
res.rowData = curTrial;
res.rowData = this.rsUpdateTrial( runID, trialID, res.rowData );
if emitUpdate
this.emit( [ 'updateRow/', run.uuid ], res );
end 
elseif ( isfield( run, 'job' ) && ismember( curTrial{ 2 }.status, { 'Complete', 'Stopped' } ) ...
 && strcmp( jobState, 'deleted' ) && curTrial{ 2 }.resultInCluster )
this.rsDiscardTrial( runID, trialID );
end 
end 
end 

function saveRresultInMap( this, runInfo )
this.resultInfo.resultMap( runInfo.runID ) = runInfo;
if isfield( runInfo, 'job' )
cluster = getCurrentCluster(  );
if ~isempty( cluster )
this.updateJobStore( 'RunInfo', runInfo, runInfo.job.ID( 2 ) );
end 
end 
end 

function onUpdateTrainingPlot( this, runID, trialID, evtSrc )
runInfo = this.resultInfo.resultMap( runID );
task = [ 'TrainingPlot_', num2str( trialID ) ];
this.updateJobStore( task, evtSrc.TrainingAxes, runInfo.job.ID( 2 ) );
end 

function addPlotUpdateListener( this, runID, trialID, src )
runInfo = this.resultInfo.resultMap( runID );
if isfield( runInfo, 'job' )
if isa( src, 'experiments.internal.CustomTrialRunner' )
obj = src;
else 
obj = src.trainingPlotter;
end 
obj.addlistener( 'UpdateTrainingPlot', @( evtSrc, ~ )this.onUpdateTrainingPlot( runID, trialID, evtSrc ) );
end 
end 
end 

methods 



function rsSetRun( this, result )
this.saveRresultInMap( result );
this.saveResults(  );
end 

function result = rsGetRun( this, runID )
result = this.resultInfo.resultMap( runID );
end 

function allRunID = rsGetAllRunID( this )
allRunID = this.resultInfo.resultMap.keys;
end 

function allRunInfo = rsGetAllRunInfo( this )
allRunInfo = sortRunInfoByStartTime( this.resultInfo.resultMap.values );
for i = 1:numel( allRunInfo )
if ~isfield( allRunInfo{ i }, 'uuid' )
allRunInfo{ i }.uuid = char( matlab.lang.internal.uuid(  ) );
this.saveRresultInMap( allRunInfo{ i } );
end 
end 
end 

function runInfoForExp = rsGetAllRunInfoForExpId( this, expId )
runInfoForExp = this.getRunInfoForExpId( expId );
if ~isempty( runInfoForExp )
runInfoForExp = sortRunInfoByStartTime( runInfoForExp );
end 
end 

function rsUpdateColumnValuesOnRestart( this, runID, data )
result = this.resultInfo.resultMap( runID );
columnValues = this.updateColumnValues( true, runID, data );
result.colValues = columnValues;
this.saveRresultInMap( result );
this.emit( [ 'updateColumnValues/', result.uuid ], columnValues );
end 


function columnValues = updateColumnValues( this, isTrialRestarted, runID, data )
result = this.resultInfo.resultMap( runID );
if result.trainingType ~= "CustomTraining"
if strcmp( result.trainingType, 'classification' )
col_id = 'Col_TrainingAccuracy';
else 
col_id = 'Col_TrainingRMSE';
end 
accIndx = length( result.paramList ) + 4;

result.colValues.( col_id ) = this.addOrRemoveColumnValues( isTrialRestarted, result.colValues.( col_id ), data{ accIndx } );
col_id = 'Col_TrainingLoss';
lossIndx = accIndx + 1;

result.colValues.( col_id ) = this.addOrRemoveColumnValues( isTrialRestarted, result.colValues.( col_id ), data{ lossIndx } );
lastIndx = lossIndx;
if result.usesValidation
validationAccIndx = lastIndx + 1;
if strcmp( result.trainingType, 'classification' )
col_id = 'Col_ValidationAccuracy';
else 
col_id = 'Col_ValidationRMSE';
end 

result.colValues.( col_id ) = this.addOrRemoveColumnValues( isTrialRestarted, result.colValues.( col_id ), data{ validationAccIndx } );
validationLossIndx = validationAccIndx + 1;
col_id = 'Col_ValidationLoss';

result.colValues.( col_id ) = this.addOrRemoveColumnValues( isTrialRestarted, result.colValues.( col_id ), data{ validationLossIndx } );
lastIndx = validationLossIndx;
end 
metricIndx = lastIndx + 1;
for i = 1:length( result.Metrics )
if ~isstruct( data{ metricIndx } )
metricName = result.Metrics( i ).name;
if isempty( result.colValues.( [ 'Col_Output_', metricName ] ) ) && islogical( data{ metricIndx } )
result.colValues.( [ 'Col_Output_', metricName ] ) = logical.empty(  );
end 
result.colValues.( [ 'Col_Output_', metricName ] ) = this.addOrRemoveColumnValues( isTrialRestarted, result.colValues.( [ 'Col_Output_', result.Metrics( i ).name ] ), data{ metricIndx } );
metricIndx = metricIndx + 1;
end 
end 
else 
for i = 1:length( result.Metrics )
indx = result.Metrics( i ).index + 1;
if ~isstruct( data{ indx } )
id = [ 'Col_Metrics_', result.Metrics( i ).name ];
if isempty( result.colValues.( id ) ) && islogical( data{ indx } )
result.colValues.( id ) = logical.empty(  );
end 
result.colValues.( id ) = this.addOrRemoveColumnValues( isTrialRestarted, result.colValues.( id ), data{ indx } );
end 
end 
for i = 1:length( result.Info )
indx = result.Info( i ).index + 1;
if ~isstruct( data{ indx } )
id = [ 'Col_Info_', result.Info( i ).name ];
if isempty( result.colValues.( id ) ) && islogical( data{ indx } )
result.colValues.( id ) = logical.empty(  );
end 
result.colValues.( id ) = this.addOrRemoveColumnValues( isTrialRestarted, result.colValues.( id ), data{ indx } );
end 
end 
end 

columnValues = result.colValues;
end 

function colValues = addOrRemoveColumnValues( this, isTrialRestarted, colValues, data )
if isTrialRestarted

colValues( find( colValues == data, 1 ) ) = [  ];
else 
colValues = sort( [ colValues, data ] );
end 
end 

function updateJobStore( ~, key, value, j2ID )
cluster = getCurrentCluster(  );
if j2ID > 0
j2 = findJob( cluster, 'ID', j2ID );
assert( ~isempty( j2 ) );
tsk = findTask( j2, 'Name', key );
if isempty( tsk )
tsk = createTask( j2, @( ~ )[  ], 0, {  }, 'Name', key );
end 
tsk.InputArguments = { value };
else 
store = getCurrentValueStore(  );
store( key ) = value;
end 
end 

function updateRunInfoTask( this, runID )
result = this.resultInfo.resultMap( runID );
assert( ~isempty( result ) );
if isfield( result, 'job' )
this.updateJobStore( 'RunInfo', result, result.job.ID( 2 ) );
end 
end 

function updateTrialDataOnRunInfoTask( this, runID, trialInd, data )
result = this.resultInfo.resultMap( runID );
if isfield( result, 'job' )
data = this.processResultData( data );
result.data{ trialInd, 1 } = data;
this.saveRresultInMap( result );
end 
end 

function data = rsUpdateTrial( this, runID, trialInd, data )
result = this.resultInfo.resultMap( runID );
if ( data{ 2 }.status == "Complete" || data{ 2 }.status == "Stopped" )
result.colValues = this.updateColumnValues( false, runID, data );
columnValues = this.rsSerializeNansInfinitys( result.colValues );
this.emit( [ 'updateColumnValues/', result.uuid ], columnValues );
end 
data = this.processResultData( data );
result.data{ trialInd, 1 } = data;
this.saveRresultInMap( result );


if data{ 2 }.status ~= "Running"
this.saveResults(  );
end 
end 

function row = processResultData( this, rowData )
for k = 1:length( rowData )
rowData{ k } = this.rsSerializeNansInfinitys( rowData{ k } );
end 
row = rowData;
end 

function rData = rsSerializeNansInfinitys( this, data )
if isStringScalar( data )
rData = data;
return ;
end 
data = convertStringsToChars( data );
rData = data;
if isstruct( data )

fNames = fieldnames( data );
for i = 1:length( fNames )
val = this.rsSerializeNansInfinitys( getfield( data, fNames{ i } ) );
data.( fNames{ i } ) = val;
end 
rData = data;
elseif iscell( data )
rData = cellfun( @this.rsSerializeNansInfinitys, data, 'UniformOutput', false );
elseif isnumeric( data ) && length( data ) > 1
rData = this.rsSerializeNansInfinitys( num2cell( data ) );
elseif ~iscategorical( data )
if isscalar( data ) && isnan( data )

rData = struct( 'type', 'InfinityNanType', 'value', num2str( data ) );
elseif isscalar( data ) && isinf( data )

rData = struct( 'type', 'InfinityNanType', 'value', [ num2str( data ), 'inity' ] );
end 
end 

end 

function data = rsGetTrial( this, runID, n )
result = this.resultInfo.resultMap( runID );
data = result.data{ n };
end 

function rsExportTable( this, runID, exportName, colNames, isForced )
if ~isvarname( exportName )
error( message( 'experiments:manager:InvalidMatlabIdentifier', exportName ) );
else 
runData = this.rsGetRun( runID ).data;
notCustom = ( this.rsGetRun( runID ).trainingType ~= "CustomTraining" );
if ~isempty( runData )
tableData = vertcat( runData{ : } );
statusData = cellfun( @( x )this.convertToCellData( x, notCustom ), tableData( :, 2 ), 'UniformOutput', false );
tableData( :, 3 ) = cellfun( @( x )this.addElapsedTime( x ), tableData( :, 3 ), 'UniformOutput', false );
numInfoCols = size( statusData{ 1 }, 2 ) + 2;
tableData = [ tableData( :, 1 ), vertcat( statusData{ : } ), tableData( :, 3:end  ) ];
colNames = string( colNames' );

colNames( 3 ) = [  ];




if notCustom
tempData = tableData( :, numInfoCols );
tableData( :, numInfoCols ) = tableData( :, numInfoCols - 1 );
tableData( :, numInfoCols - 1 ) = tempData;
end 
exportTableInfo = cell2table( tableData( :, 1:numInfoCols ), 'VariableNames', colNames( 1:numInfoCols ) );

result = this.resultInfo.resultMap( runID );
num_params = length( result.paramList );

exportTableParams = cell2table( tableData( :, numInfoCols + 1:numInfoCols + num_params ), 'VariableNames', colNames( numInfoCols + 1:numInfoCols + num_params ) );
exportTableParams = mergevars( exportTableParams, result.paramList, 'NewVariableName', message( 'experiments:results:Hyperparameters' ).getString(  ), 'MergeAsTable', true );

metricColumnNames = colNames( ( numInfoCols + num_params + 1 ):end  );
tableData( :, numInfoCols + num_params + 1:end  ) = cellfun( @( x )this.treatMissing( x ), tableData( :, numInfoCols + num_params + 1:end  ), 'UniformOutput', false );
exportTableMetrics = cell2table( tableData( :, numInfoCols + num_params + 1:end  ), 'VariableNames', metricColumnNames );
exportTableMetrics = mergevars( exportTableMetrics, metricColumnNames, 'NewVariableName', message( 'experiments:results:Metrics' ).getString(  ), 'MergeAsTable', true );
exportTable = [ exportTableInfo, exportTableParams, exportTableMetrics ];
if ~isForced && evalin( 'base', sprintf( 'exist(''%s'',''%s'')', exportName, 'var' ) )
error( message( 'experiments:manager:ExportNameExistException' ) );
else 
assignin( 'base', exportName, exportTable );
end 
else 
error( message( 'experiments:manager:ExportDoesNotExistError' ) );
end 
end 

end 

function elapsedTime = addElapsedTime( ~, columnData )
if ~isempty( columnData.completionTime )
elapsedTime = datetime( columnData.completionTime, 'TimeZone', 'local', 'InputFormat', 'yyyy-MM-dd''T''HH:mm:ssXXX' ) - datetime( columnData.startTime, 'TimeZone', 'local', 'InputFormat', 'yyyy-MM-dd''T''HH:mm:ssXXX' );
else 
elapsedTime = duration( '00:00:00' );
end 
end 

function statusData = convertToCellData( ~, structData, notCustom )
if isfield( structData, 'text' ) && ~isempty( structData.text )
statusTextKey = append( 'experiments:results:', structData.text );
statusData = { string( append( structData.status, message( statusTextKey ).getString(  ) ) ), double( structData.progressPercent ) };
else 
statusData = { string( structData.status ), double( structData.progressPercent ) };
end 
if isfield( structData, 'executionEnvironment' )
ExecutionEnvironment = structData.executionEnvironment.ExecutionEnvironment;
UseParallel = structData.executionEnvironment.UseParallel;
newData = "";
if ( ExecutionEnvironment == "cpu" )
if ( UseParallel )
newData = string( message( 'experiments:results:ExecutionEnvironmentValueParallelCPU' ).getString(  ) );
else 
newData = string( message( 'experiments:results:ExecutionEnvironmentValueSerialCPU' ).getString(  ) );
end 
elseif ( ExecutionEnvironment == "gpu" )
if ( UseParallel )
newData = string( message( 'experiments:results:ExecutionEnvironmentValueParallelGPU' ).getString(  ) );
else 
newData = string( message( 'experiments:results:ExecutionEnvironmentValueSerialGPU' ).getString(  ) );
end 
end 
statusData = { statusData{ : }, newData };
else 
if notCustom





statusData = { statusData{ : }, "" };
end 
end 

end 

function x = treatMissing( ~, x )
if isequal( x, 'NA' ) || isstruct( x )
x = missing;
end 
end 

function rsExport( this, runID, trialIndx, exportName, exportType, isForced )
if ~isvarname( exportName )
error( message( 'experiments:manager:InvalidMatlabIdentifier', exportName ) );
else 
filePath = fullfile( this.resultsDir, runID, [ 'Trial_', num2str( trialIndx ) ], 'output.mat' );
if exist( filePath, 'file' )
if strcmp( exportType, 'trainingInfo' )
out = load( filePath, 'trInfo' );
out = out.trInfo;
elseif strcmp( exportType, 'trainedNetwork' )
out = load( filePath, 'nnet' );
out = out.nnet;
elseif strcmp( exportType, 'trainingOutput' )
out = load( filePath );
end 
if ~isForced && evalin( 'base', sprintf( 'exist(''%s'',''%s'')', exportName, 'var' ) )
error( message( 'experiments:manager:ExportNameExistException' ) );
else 
assignin( 'base', exportName, out );
end 
else 
error( message( 'experiments:manager:ExportDoesNotExistError' ) );
end 
end 

end 

function environmentInfo = rsReadEnvironmentInfo( this, runID )
environmentInfo = [  ];
if this.feature.captureWorkerInfo
filePath = fullfile( this.resultsDir, runID, 'Snapshot', 'environmentInfo.mat' );
environmentInfo = load( filePath );
end 
end 

function rsDeleteRun( this, runID )
runDir = fullfile( this.resultsDir, runID );
if exist( runDir, 'dir' )

status = rmdir( runDir, 's' );
if ~status
error( message( 'experiments:results:DeleteOperationError' ) );
end 
end 

remove( this.resultInfo.resultMap, runID );
this.saveResults(  );
end 

function rsDiscardTrial( this, runID, trialID )
run = this.rsGetRun( runID );
trialDir = fullfile( fullfile( this.getResultsDir(  ), runID ), [ 'Trial_', num2str( trialID ) ] );
if exist( trialDir, 'dir' )

delete( fullfile( trialDir, '*' ) );
else 
error( message( 'experiments:results:TrialFolderNotFound' ) );
end 
curTrial = this.rsGetTrial( runID, trialID );
curTrial{ 2 }.status = 'Discarded';
res.rowInd = trialID - 1;
res.rowData = curTrial;
res.rowData = this.rsUpdateTrial( runID, trialID, res.rowData );
this.emit( [ 'updateRow/', run.uuid ], res );
end 


function name = rsGetUniqueWorkspaceName( this, exportType )
existingNames = evalin( 'base', 'who' );
name = matlab.lang.makeUniqueStrings( exportType, existingNames );
end 

function rsRenameRun( this, info )
runID = info.runID;
result = this.resultInfo.resultMap( runID );


runInfoForExp = this.getRunInfoForExpId( result.expId );
if ~isempty( runInfoForExp )

if any( cellfun( @( r )strcmp( r.runLabel, info.newLabel ), runInfoForExp ) )
errME = MException( message( 'experiments:project:ResultLabelAlreadyExistsForExperiment',  ...
info.newLabel ) );
throw( errME );
end 
end 

result.runLabel = info.newLabel;
this.saveRresultInMap( result );
this.saveResults(  );
this.emit( [ 'renameResult/', result.uuid ], info.newLabel );
end 

function rsOpenSnapshotFile( this, runID, snapshotFile )
snapshotFile = regexprep( snapshotFile, '[\\/]', filesep );
path = fullfile( this.resultsDir, runID, 'Snapshot', snapshotFile );
this.prjOpenFile( path );
end 
end 

methods ( Access = private )

function initResultService( this, evtData )
this.resultsDir = fullfile( evtData.data, 'Results' );

this.loadResultInfoFile(  );
end 

function closeResultService( this )
this.reset(  );
end 

function saveResults( this )
if this.suspendSaveResultCount > 0
return ;
end 
resultInfoFile = this.getResultInfoFile(  );
resultInfo = this.resultInfo;

if ~exist( this.resultsDir, 'dir' )
mkdir( this.resultsDir );
end 
save( resultInfoFile, 'resultInfo' );
end 

function reset( this )

this.resultInfo.resultMap = containers.Map( 'KeyType', 'char', 'ValueType', 'any' );
end 

function resultInfoFile = getResultInfoFile( this )
resultInfoFile = fullfile( this.resultsDir, 'resultInfo.mat' );
end 

function loadResultInfoFile( this )
resultInfoFile = this.getResultInfoFile(  );
if exist( resultInfoFile, 'file' )
file = load( resultInfoFile );
this.resultInfo = file.resultInfo;
allRunID = this.rsGetAllRunID(  );
for k = 1:length( allRunID )
currentRunID = allRunID{ k };
this.cancelTrials( currentRunID, false );
end 
else 
this.resultInfo = experiments.internal.ResultInfo(  );
end 
end 

function runInfoForExp = getRunInfoForExpId( this, expId )
allRunInfo = this.resultInfo.resultMap.values;
runInfoForExp = allRunInfo( cellfun( @( r )strcmp( r.expId, expId ),  ...
allRunInfo ) );
end 

end 
end 

function allRunInfo = sortRunInfoByStartTime( allRunInfo )
startTimes = cellfun( @( info )datetime( info.startTime,  ...
'InputFormat', 'yyyy-MM-dd''T''HH:mm:ssZ', 'TimeZone', 'local' ), allRunInfo );

[ ~, idx ] = sort( startTimes );
allRunInfo = allRunInfo( idx );
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpXuSd59.p.
% Please follow local copyright laws when handling this file.

