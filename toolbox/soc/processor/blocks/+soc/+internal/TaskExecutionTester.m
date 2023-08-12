classdef ( Sealed = false )TaskExecutionTester < matlab.mixin.SetGet























properties ( Access = 'public' )






SDIRuns = {  };




Tasks = 'all';




ModelName = '';



BaseValue = eps;





MaxDifference = 0;





MaxDifferenceRelative = true;


























ComparisonMethod = { 'MeanDuration' };






Timeout = 10;





Trim = false;

PlotViolations = false;

CreateSummaryReport = false;

FirstRunBaseline = true;
end 
properties ( Access = 'private' )
TaskRunning = soc.profiler.TaskState.Running;
TaskReady = soc.profiler.TaskState.Ready;
TaskWaiting = soc.profiler.TaskState.Waiting;
SimulationTypeLabel = { 'normal', 'external' };
IsLoaded = false;
TaskManagerData;
Profiling;
SimulationMode;
TaskMgr;
end 
properties ( Access = 'public', Hidden )
CurrentRuns = {  };
end 

methods 
function set.ModelName( h, val )
if ~ischar( val ) && ~isstring( val )
errID = 'soc:scheduler:TesterInvalidValueForChar';
error( message( errID, 'ModelName' ) );
end 
h.ModelName = char( val );
end 
function set.MaxDifference( h, val )
if ~isnumeric( val ) || ~isreal( val ) || ~isscalar( val ) || ( val < 0 )
errID = 'soc:scheduler:TesterInvalidValueForRealNonNeg';
error( message( errID, 'MaxDifference' ) );
end 
h.MaxDifference = val;
end 
function set.MaxDifferenceRelative( h, val )
if ~islogical( val ) || ~isreal( val ) || ~isscalar( val )
errID = 'soc:scheduler:TesterInvalidValueForLogical';
error( message( errID, 'MaxDifferenceRelative' ) );
end 
h.MaxDifferenceRelative = val;
end 
function set.Timeout( h, val )
if ~isnumeric( val ) || ~isreal( val ) || ~isscalar( val ) || ( val < 0 )
errID = 'soc:scheduler:TesterInvalidValueForRealNonNeg';
error( message( errID, 'Timeout' ) );
end 
h.Timeout = val;
end 
function set.Trim( h, val )
if ~islogical( val ) || ~isreal( val ) || ~isscalar( val )
errID = 'soc:scheduler:TesterInvalidValueForLogical';
error( message( errID, 'Trim' ) );
end 
h.Trim = val;
end 
function set.PlotViolations( h, val )
if ~islogical( val ) || ~isreal( val ) || ~isscalar( val )
errID = 'soc:scheduler:TesterInvalidValueForLogical';
error( message( errID, 'PlotViolations' ) );
end 
h.PlotViolations = val;
end 
function set.CreateSummaryReport( h, val )
if ~islogical( val ) || ~isreal( val ) || ~isscalar( val )
errID = 'soc:scheduler:TesterInvalidValueForLogical';
error( message( errID, 'CreateSummaryReport' ) );
end 
h.CreateSummaryReport = val;
end 
function set.FirstRunBaseline( h, val )
if ~islogical( val ) || ~isreal( val ) || ~isscalar( val )
errID = 'soc:scheduler:TesterInvalidValueForLogical';
error( message( errID, 'FirstRunBaseline' ) );
end 
h.FirstRunBaseline = val;
end 
function set.Tasks( h, tasks )
if isequal( tasks, 'all' ), return ;end 
if ~iscell( tasks )
tasks = { tasks };
end 
for i = 1:numel( tasks )
if ~ischar( tasks{ i } ) || isempty( tasks{ i } )
errID = 'soc:scheduler:TesterInvalidTaskName';
error( message( errID, tasks{ i } ) );
end 
end 
h.Tasks = tasks;
end 
function set.SDIRuns( h, sdiRuns )
if ~iscell( sdiRuns ) || numel( sdiRuns ) > 2
errID = 'soc:scheduler:TesterInvalidNumSDIRuns';
error( message( errID ) );
end 
for i = 1:numel( sdiRuns )
sdiRuns{ i } = convertStringsToChars( sdiRuns{ i } );
end 
runIDs = zeros( 1, numel( sdiRuns ) );
for i = 1:numel( sdiRuns )
run = soc.internal.sdi.getRun( sdiRuns{ i } );
if ~isempty( run )
runIDs( i ) = run.id;
else 
errID = 'soc:scheduler:TesterSDIRunNotFound';
error( message( errID, sdiRuns{ i } ) );
end 
end 
h.SDIRuns = sdiRuns;
end 
function set.ComparisonMethod( h, compMethod )
supCompMethods = { 'MeanDuration',  ...
'InstanceDuration', 'InstanceTimes', 'NumOverruns' };
if ~ischar( compMethod ) && ~isstring( compMethod )
errID = 'soc:scheduler:TesterInvalidValueForChar';
error( message( errID, 'ComparisonMethod' ) );
end 
if ~ismember( compMethod, ( supCompMethods ) )
str = '';
for i = 1:numel( supCompMethods )
if ( i < numel( supCompMethods ) )
fill = ', ';
else 
fill = '';
end 
str = [ str, supCompMethods{ i }, fill ];%#ok<AGROW>
end 
errID = 'soc:scheduler:TesterInvalidComparisonMethod';
error( message( errID, compMethod, str ) );
end 
h.ComparisonMethod = { char( compMethod ) };
end 
end 
methods ( Access = 'public', Hidden )
function results = runAnalysisOnly( h )
h.basicChecks(  );
allMdlNames = {  };
simRunIDs = Simulink.sdi.getAllRunIDs;
for i = 1:numel( simRunIDs )
run = Simulink.sdi.getRun( simRunIDs( i ) );
allMdlNames{ end  + 1 } = run.Model;%#ok<AGROW>
end 

[ simFound, idxSim ] = ismember( [ h.ModelName ], allMdlNames( 1 ) );
[ diaFound, idxDia ] = ismember( [ h.ModelName ], allMdlNames( 2 ) );
idxDia = idxDia + 1;

assert( simFound, 'Simulation profiling results not found in SDI.' );
assert( diaFound, 'Processor profiling results not found in SDI.' );
assert( isscalar( idxSim ), 'Multiple simulation profiling results found in SDI.' );
assert( isscalar( idxDia ), 'Multiple processor profiling results not found in SDI.' );
simRunID = simRunIDs( idxSim );
diaRunID = simRunIDs( idxDia );
allTaskData = get_param( h.TaskMgr, 'AllTaskData' );
taskMgrData = soc.internal.TaskManagerData( allTaskData, 'evaluate', h.ModelName );
simRunSigNames = taskMgrData.getTaskNames;
results = [  ];
idx = 0;
for i = 1:numel( simRunSigNames )
taskName = simRunSigNames{ i };
simData = h.getTaskData( simRunID, taskName );
diaData = h.getTaskData( diaRunID, taskName );
idx = idx + 1;
results{ idx } = h.getTestResults( taskName, simData, diaData );%#ok<AGROW>
if h.PlotViolations
switch h.ComparisonMethod{ 1 }
case 'InstanceDuration'
h.plotTaskDurationViolations( results );
case 'InstanceTimes'
h.plotTaskInstanceViolations( results );
case 'NumOverruns'
h.plotNumOverrunsViolations( results );
end 
end 
end 
end 
end 
methods ( Access = 'public' )
function h = TaskExecutionTester( modelName, varargin )
if ( 1 == nargin )
h.ModelName = modelName;
mgrBlk = soc.internal.connectivity.getTaskManagerBlock(  ...
modelName, true );
if isempty( mgrBlk )
error( message( 'soc:scheduler:NoTaskManager', modelName ) )
end 





assert( ~iscell( mgrBlk ), 'Multiple Task Managers Found' );
h.TaskMgr = mgrBlk;
elseif ( 2 == nargin )
h.ModelName = modelName;
h.TaskMgr = varargin{ 1 };
end 
end 
function results = run( h )


















































c = onCleanup( @(  )h.onRunCleanup(  ) );
h.basicChecks(  );
if isempty( h.SDIRuns )
results = h.testSimVsHW;
elseif numel( h.SDIRuns ) == 1
h.CurrentRuns = h.SDIRuns;
results = h.testRun;
elseif numel( h.SDIRuns ) == 2
h.CurrentRuns = h.SDIRuns;
results = h.testRunVsRun;
else 
assert( false, 'Number of SDI runs should be 0, 1, or 2.' );
end 
if h.PlotViolations
switch h.ComparisonMethod{ 1 }
case 'InstanceDuration'
h.plotTaskDurationViolations( results );
case 'InstanceTimes'
h.plotTaskInstanceViolations( results );
case 'NumOverruns'
h.plotNumOverrunsViolations( results );
end 
end 
if h.CreateSummaryReport
soc.internal.createTaskExecutionReport( h, results,  ...
h.ModelName );
end 
end 
end 
methods ( Access = private )
function ret = isRunVsRun( h )
ret = ( numel( h.SDIRuns ) == 2 ) || ( numel( h.SDIRuns ) == 0 );
end 
function viewer = createSignalViewer( h, sigName, ending, dType )
postfix = '_comparison';
runName = [ h.ModelName, postfix ];
sigName = [ sigName, ':', ending ];
viewer = soc.profiler.ToAsyncQueueSignalView( runName,  ...
sigName, zeros( 1, 1, dType ), 0, true, 0 );
end 
function startViewer( h, intrumenationModelName )
soc.profiler.startView( intrumenationModelName );
hmiOpts.RecordOn = 1;
hmiOpts.VisualizeOn = 1;
hmiOpts.CommandLine = false;
hmiOpts.StartTime = get_param( h.ModelName, 'SimulationTime' );
hmiOpts.StopTime = inf;
try 
hmiOpts.StopTime = evalin( 'base', get_param( h.ModelName, 'StopTime' ) );
catch 
hmiOpts.StopTime = inf;
end 
hmiOpts.EnableRollback = slprivate( 'onoff', get_param( h.ModelName, 'EnableRollback' ) );
hmiOpts.SnapshotInterval = get_param( h.ModelName, 'SnapshotInterval' );
hmiOpts.NumberOfSteps = get_param( h.ModelName, 'NumberOfSteps' );
Simulink.HMI.slhmi( 'sim_start', intrumenationModelName, hmiOpts );
end 
function basicChecks( h )
if isempty( h.ModelName ) && isequal( h.ComparisonMethod{ 1 }, 'NumOverruns' )
errID = 'soc:scheduler:TesterInvalidComparisonWithoutModel';
error( message( errID ) );
end 
if h.MaxDifferenceRelative && isequal( h.ComparisonMethod{ 1 }, 'InstanceTimes' )
errID = 'soc:scheduler:TesterInvalidComparisonWithRelative';
error( message( errID ) );
end 
end 
function name = getNameForComaprisonRun( h )
baseName = h.ModelName;
if isempty( baseName ), baseName = 'untitled';end 
name = [ baseName, '_comparison' ];
end 
function results = testRunVsRun( h )
assert( numel( h.SDIRuns ) == 2, 'You must specify two runs or leave the Runs empty' );
run1 = soc.internal.sdi.getRun( h.SDIRuns{ 1 } );
assert( ~isempty( run1 ), [ 'Cannot find the run named ', h.SDIRuns{ 1 }, ' in SDI' ] );
run2 = soc.internal.sdi.getRun( h.SDIRuns{ 2 } );
assert( ~isempty( run2 ), [ 'Cannot find the run named ', h.SDIRuns{ 2 }, ' in SDI' ] );
run1ID = run1.id;
run2ID = run2.id;
results = collectResults( h, run1ID, run2ID );
end 
function results = testRun( h )
h.prepareForRun(  );
run1 = soc.internal.sdi.getRun( h.SDIRuns{ 1 } );
assert( ~isempty( run1 ),  ...
[ 'Cannot find the run named ', h.SDIRuns{ 1 }, ' in SDI' ] );
run1ID = run1.id;
results = collectResults( h, run1ID );
end 
function results = testSimVsHW( h )
h.prepareForRunOnHW(  );
simRunID = h.runInSim(  );
thisRun = Simulink.sdi.getRun( simRunID );
h.CurrentRuns{ 1 } = thisRun.Name;
extRunID = h.runOnHW(  );
thisRun = Simulink.sdi.getRun( extRunID );
h.CurrentRuns{ 2 } = thisRun.Name;
results = h.collectResults( simRunID, extRunID );
end 
function prepareForRun( h )
h.IsLoaded = bdIsLoaded( h.ModelName );
if ~h.IsLoaded
load_system( h.ModelName );
end 
end 
function prepareForRunOnHW( h )
h.prepareForRun(  );
hCS = getActiveConfigSet( h.ModelName );
hwInfo = codertarget.targethardware.getTargetHardware( hCS );
if hwInfo.SupportsOnlySimulation
error( message( 'soc:utils:ExecTesterHWBoardSimOnly',  ...
get_param( h.ModelName, 'HardwareBoard' ) ) );
end 
h.SimulationMode = get_param( h.ModelName, 'SimulationMode' );
h.Profiling = get_param( h.ModelName, 'CodeExecutionProfiling' );
h.TaskManagerData = get_param( h.TaskMgr, 'AllTaskData' );
time = str2double( get_param( h.ModelName, 'StopTime' ) );
if isinf( time )
error( message( 'soc:scheduler:StopTimeInf' ) );
end 
h.setTasksForLogging(  );
end 
function id = runInSim( h )
runIDsAtStart = Simulink.sdi.getAllRunIDs;
try 
disp( 'Profiling task execution in simulation ...' );
set_param( h.ModelName, 'SimulationMode', 'normal' );
set_param( h.ModelName, 'SolverType', 'Variable-step' );
set_param( h.ModelName, 'SimulationCommand', 'start' );
h.blockUntilSimStopsLimited;
id = h.getSDIRunForTest( runIDsAtStart, 'normal' );
catch ME
error( message( 'soc:scheduler:TesterSimulationFailed',  ...
h.ModelName, ME.message ) );
end 
end 
function id = runOnHW( h )
runIDsAtStart = Simulink.sdi.getAllRunIDs;
try 
disp( 'Profiling task execution on hardware ...' );
set_param( h.ModelName, 'SimulationMode', 'external' );
set_param( h.ModelName, 'SolverType', 'Fixed-step' );
set_param( h.ModelName, 'SimulationCommand', 'start' );
h.blockUntilSimStopsLimited;
id = h.getSDIRunForTest( runIDsAtStart, 'external' );
catch ME
error( message( 'soc:scheduler:TesterExternalModeFailed',  ...
h.ModelName, ME.message ) );
end 
end 
function res = collectResults( h, run1ID, run2ID )
try 
res = [  ];
if isequal( h.Tasks, 'all' )
allTaskData = get_param( h.TaskMgr, 'AllTaskData' );
taskMgrData = soc.internal.TaskManagerData( allTaskData, 'evaluate', h.ModelName );
sigNamesToTest = taskMgrData.getTaskNames;
else 
sigNamesToTest = h.Tasks;
end 
for i = 1:numel( sigNamesToTest )
taskName = sigNamesToTest{ i };
if h.isRunVsRun(  )
run1Data = h.getTaskData( run1ID, taskName );
run2Data = h.getTaskData( run2ID, taskName );
res{ i } = h.getTestResults( taskName, run1Data, run2Data );%#ok<AGROW>
else 
run1Data = h.getTaskData( run1ID, taskName );
res{ i } = h.getTestResults( taskName, run1Data );%#ok<AGROW>
end 
end 
catch ME
error( message( 'soc:scheduler:TesterInvalidTaskData',  ...
ME.message ) );
end 
end 
function onRunCleanup( h )
while ~isequal( get_param( h.ModelName, 'SimulationStatus' ), 'stopped' )


end 
if isempty( h.SDIRuns )
if ~isempty( h.SimulationMode )
set_param( h.ModelName, 'SimulationMode', h.SimulationMode );
end 
if ~isempty( h.Profiling )
set_param( h.ModelName, 'CodeExecutionProfiling',  ...
h.Profiling );
end 
if ~isempty( h.TaskManagerData )
set_param( h.TaskMgr, 'AllTaskData', h.TaskManagerData );
end 
if ~h.IsLoaded
close_system( h.ModelName, 0 );
end 
end 
end 
end 
methods ( Access = private )
function id = getSDIRunForTest( h, runIDsAtStart, lbl )
[ res, ~ ] = ismember( lbl, h.SimulationTypeLabel );
assert( res, [ 'getSDIRunForTest:runLabel', lbl, 'invalid.' ] );

runIDsNow = Simulink.sdi.getAllRunIDs;
runIDsNew = setdiff( runIDsNow, runIDsAtStart );
newRuns = arrayfun( @( x )Simulink.sdi.getRun( x ), runIDsNew );
theModelNameToMatch = [ h.ModelName ];
idx = arrayfun( @( x )isequal( x.Model, theModelNameToMatch ),  ...
newRuns, 'UniformOutput', false );
[ ~, theIdx ] = find( [ idx{ : } ] );
id = runIDsNew( theIdx );
if isempty( id )
msg = DAStudio.message( 'soc:scheduler:NoSDIRunFound', lbl );
ME = MException( 'soc:scheduler:TesterFailed', msg );
throw( ME );
end 
end 
function res = getTestResults( h, taskName, run1Data, run2Data )
res.Task = taskName;
res.Run1Data = run1Data;
res.Passed = true;
res.Violations = [  ];
res.Warnings = [  ];
res.Messages = {  };
if h.isRunVsRun(  )
res.Run2Data = run2Data;
end 

res = h.doCommonChecks( res );
if ~isempty( res.Violations ), return ;end 

if h.isRunVsRun(  )

switch ( h.ComparisonMethod{ 1 } )
case 'MeanDuration'
res = h.checkMeanDuration( res );
case 'InstanceDuration'
res = h.checkInstanceDurationRunVsRun( res );
case 'InstanceTimes'
res = h.checkInstanceTimes( res );
case 'NumOverruns'
res = h.checkNumOverruns( res );
otherwise 
assert( false, 'Invalid Comparison Method' );
end 
else 
switch ( h.ComparisonMethod{ 1 } )
case 'MeanDuration'
res = h.checkMeanDuration( res );
case 'InstanceDuration'
res = h.checkInstanceDuration( res );
case 'InstanceTimes'
res = h.checkInstanceTimes( res );
case 'NumOverruns'
res = h.checkNumOverruns( res );
otherwise 
assert( false, 'Invalid Comparison Method' );
end 
end 
end 
function data = getTaskData( ~, runID, taskName )
rawData = soc.internal.sdi.getSignalData( runID, taskName );
if ~isempty( rawData.Data )
data.StartTimes = soc.internal.sdi.getTaskStartTimes( rawData );
data.EndTimes = soc.internal.sdi.getTaskEndTimes( rawData );
data.Durations = soc.internal.sdi.getTaskDurations( rawData );
L = min( [ length( data.StartTimes ), length( data.EndTimes ),  ...
length( data.Durations ) ] );
data.StartTimes = data.StartTimes( 1:L );
data.EndTimes = data.EndTimes( 1:L );
data.Durations = data.Durations( 1:L );
else 
data.StartTimes = [  ];
data.EndTimes = [  ];
data.Durations = [  ];
end 
end 
function setTasksForLogging( h )
set_param( h.TaskMgr, 'StreamToSDI', 'on' );
set_param( h.ModelName, 'CodeExecutionProfiling', 'on' );
end 
function taskBlocks = getTaskBlocks( h )


taskBlocks = find_system( h.ModelName, 'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices, 'MaskType', 'ESB Task' );
end 
function taskNames = getTaskNames( h )
taskBlocks = getTaskBlocks( h );
taskNames = {  };
for i = 1:numel( taskBlocks )
taskNames{ end  + 1 } = get_param( taskBlocks{ i }, 'taskName' );%#ok<AGROW>
end 
end 

function blockUntilSimStopsLimited( h )
stopTime = str2double( get_param( h.ModelName, 'StopTime' ) );
timeout = stopTime + h.Timeout;
while ( timeout )
pause( 1 );
timeout = timeout - 1;
st = get_param( h.ModelName, 'SimulationStatus' );
if isequal( st, 'stopped' )
break ;
end 
assert( timeout > 0,  ...
'The simulation did not complete in the expected time' );
end 
end 

function res = doCommonChecks( h, res )
if isequal( h.ComparisonMethod{ 1 }, 'MeanDuration' ) &&  ...
h.PlotViolations
res.Warnings( end  + 1 ).Type = 'IncompatibleSettings';
res.Warnings( end  ).Msg{ 1 } =  ...
[ 'When ComparisonMethod is set to MeanDuration, ' ...
, 'the PlotViolations setting is ignored since the ' ...
, 'violations value is scalar.' ];
end 
if ~isfield( res, 'Run2Data' )
res.Warnings( end  + 1 ).Type = 'IncompatibleSettings';
res.Warnings( end  ).Msg{ 1 } =  ...
[ 'When one SDI run is provided, the ComparisonMethod ' ...
, 'setting is ignored as there is nothing to compare to.' ];
end 
if isfield( res, 'Run2Data' ) && ~isequal( length( res.Run2Data ), length( res.Run1Data ) )
res.Warnings( end  + 1 ).Type = 'DifferentResultLengths';
res.Warnings( end  ).Msg{ 1 } =  ...
[ 'Different number of recorded task instances ' ...
, 'obtained in two runs.' ];
end 
end 

function res = checkMeanDuration( h, res )
if h.isRunVsRun(  )
if h.FirstRunBaseline
baseDurMean = mean( res.Run1Data.Durations );
compDurMean = mean( res.Run2Data.Durations );
else 
baseDurMean = mean( res.Run2Data.Durations );
compDurMean = mean( res.Run1Data.Durations );
end 
else 
compDurMean = mean( res.Run1Data.Durations );
baseDurMean = h.BaseValue;
end 
delta = abs( compDurMean - baseDurMean );
if h.MaxDifferenceRelative
delta = 100 * ( delta / baseDurMean );
end 
res.Passed = delta <= h.MaxDifference;
if ~res.Passed
res.Violations( end  + 1 ).Type = 'DifferentMeanDuration';
res.Violations( end  ).Msg{ 1 } =  ...
[ 'The difference between the mean task durations ' ...
, 'obtained in two runs ', num2str( delta ), ' is greater ' ...
, 'than the value you specified ' ...
, num2str( h.MaxDifference ), '%' ];
res.Violations( end  ).MeanDiff = delta;
else 
res.Messages{ end  + 1 } =  ...
[ 'The difference between the mean task durations ' ...
, 'obtained in two runs ', num2str( delta ), ' is less ' ...
, 'or equal than the value you specified ' ...
, num2str( h.MaxDifference ), '%' ];
end 
end 

function res = checkInstanceDuration( h, res )
run1Data = res.Run1Data;
run1Length = length( run1Data.Durations );
startIdx = 1;
endIdx = startIdx + run1Length - 1;

compData = run1Data;

dur1 = compData.Durations( startIdx:endIdx );

delta = abs( dur1 - h.BaseValue );
if h.MaxDifferenceRelative
delta = 100 * ( delta / h.BaseValue );
end 
diffIdx = ( delta > h.MaxDifference );
res.Passed = ~any( diffIdx );
if ~res.Passed
res.Violations( end  + 1 ).Type = 'DifferentInstanceDuration';
res.Violations( end  ).Run1Data.StartTimes = res.Run1Data.StartTimes( diffIdx );
res.Violations( end  ).Run1Data.Durations = res.Run1Data.Durations( diffIdx );
res.Violations( end  ).Msg{ 1 } =  ...
[ 'The differences between the task durations obtained in ' ...
, 'two runs is greater than the value you specified ' ...
, 'of ', num2str( h.MaxDifference ), '.' ];
res.Violations( end  ).Msg{ 2 } =  ...
[ 'The total number of such differences is ' ...
, num2str( sum( diffIdx ) ), '.' ];
if h.PlotViolations
if h.MaxDifferenceRelative
str = '%';
s = 'relative';
else 
str = '';
s = 'absolute';
end 
sigName = [ res.Task, ': ', h.ComparisonMethod{ 1 }, ' violations ', str ];
sigName = [ '''', sigName, '''' ];
res.Violations( end  ).Msg{ 3 } =  ...
[ 'If a difference between the task duration at a task ' ...
, 'instance is greater than the value you specified, ' ...
, 'you may view the differences as the signal ', sigName, ' ' ...
, 'in Simulation Data Inspector. The signal value at ' ...
, 'each instance is equal to the value of the ', s, ' ' ...
, 'difference.' ];
end 
end 
end 

function res = checkInstanceDurationRunVsRun( h, res )
run1Data = res.Run1Data;
run2Data = res.Run2Data;
run1Length = length( run1Data.Durations );
run2Length = length( run2Data.Durations );
if h.Trim
minLength = min( run1Length, run2Length );
else 
if ~isequal( run1Length, run2Length ) && ~h.Trim
res.Warnings( end  + 1 ).Type = 'DifferentResultLengths';
res.Warnings( end  ).Msg{ 1 } = [ 'Different number of recorded ' ...
, 'task instances obtained in two runs.' ];
end 
if h.FirstRunBaseline
minLength = run1Length;
else 
minLength = run2Length;
end 
end 

startIdx = 1;
endIdx = startIdx + minLength - 1;

if h.FirstRunBaseline
baseData = run1Data;
compData = run2Data;
else 
baseData = run2Data;
compData = run1Data;
end 

dur1 = compData.Durations( startIdx:endIdx );
dur2 = baseData.Durations( startIdx:endIdx );

delta = abs( dur1 - dur2 );
if h.MaxDifferenceRelative
delta = 100 * ( delta ./ baseData.Durations( startIdx:endIdx ) );
end 
diffIdx = ( delta > h.MaxDifference );
res.Passed = ~any( diffIdx );
if ~res.Passed
res.Violations( end  + 1 ).Type = 'DifferentInstanceDuration';
res.Violations( end  ).Run2Data.StartTimes = res.Run2Data.StartTimes( diffIdx );
res.Violations( end  ).Run1Data.StartTimes = res.Run1Data.StartTimes( diffIdx );
res.Violations( end  ).Run2Data.Durations = res.Run2Data.Durations( diffIdx );
res.Violations( end  ).Run1Data.Durations = res.Run1Data.Durations( diffIdx );
res.Violations( end  ).Msg{ 1 } =  ...
[ 'The differences between the task durations obtained in ' ...
, 'two runs is greater than the value you specified ' ...
, 'of ', num2str( h.MaxDifference ), '.' ];
res.Violations( end  ).Msg{ 2 } =  ...
[ 'The total number of such differences is ' ...
, num2str( sum( diffIdx ) ), '.' ];
if h.PlotViolations
if h.MaxDifferenceRelative
str = '%';
s = 'relative';
else 
str = '';
s = 'absolute';
end 
sigName = [ res.Task, ': ', h.ComparisonMethod{ 1 }, ' violations ', str ];
sigName = [ '''', sigName, '''' ];
res.Violations( end  ).Msg{ 3 } =  ...
[ 'If a difference between the task duration at a task ' ...
, 'instance is greater than the value you specified, ' ...
, 'you may view the differences as the signal ', sigName, ' ' ...
, 'in Simulation Data Inspector. The signal value at ' ...
, 'each instance is equal to the value of the ', s, ' ' ...
, 'difference.' ];
end 
end 
end 

function res = checkInstanceTimes( h, res )
if h.FirstRunBaseline
baseData = res.Run1Data;
compData = res.Run2Data;
else 
baseData = res.Run2Data;
compData = res.Run1Data;
end 
sameLength =  ...
isequal( length( compData.StartTimes ), length( baseData.StartTimes ) ) &&  ...
isequal( length( compData.EndTimes ), length( baseData.EndTimes ) );
if ~sameLength && ~h.Trim
res.Warnings( end  + 1 ).Type = 'DifferentResultLengths';
res.Warnings( end  ).Msg{ 1 } =  ...
[ 'Different number of recorded task start or task end ' ...
, 'instances obtained in two runs.' ];
end 

L1 = min( length( compData.StartTimes ), length( baseData.StartTimes ) );
compStarts = compData.StartTimes( 1:L1 );
baseStarts = baseData.StartTimes( 1:L1 );
delta = abs( compStarts - baseStarts );
startIdx = ( delta > h.MaxDifference );
res.Passed = ~any( startIdx );

if ~res.Passed
res.Violations( end  + 1 ).Type = 'DifferentInstanceTimes';
res.Violations( end  ).Run2Data.StartTimes =  ...
res.Run2Data.StartTimes( startIdx );
res.Violations( end  ).Run1Data.StartTimes =  ...
res.Run1Data.StartTimes( startIdx );
res.Violations( end  ).Msg{ 1 } =  ...
[ 'The differences between the task start times obtained in ' ...
, 'two runs is greater than the ' ...
, 'value you specified of ', num2str( h.MaxDifference ), '%' ];
res.Violations( end  ).Msg{ 2 } =  ...
[ 'The total number of such differences is ' ...
, num2str( sum( startIdx ) ), '.' ];
if h.PlotViolations
sigName = [ res.Task, ': ', h.ComparisonMethod{ 1 }, ' violations ' ];
sigName = [ '''', sigName, '''' ];
res.Violations( end  ).Msg{ 3 } =  ...
[ 'If a difference between the task start time at a task ' ...
, 'instance is greater than the value you specified, ' ...
, 'you may view the differences as the signal ', sigName, ' ' ...
, 'in Simulation Data Inspector. The signal value at ' ...
, 'each instance is equal to the value of the absolute ' ...
, 'difference.' ];
end 
else 
res.Messages{ end  + 1 } =  ...
[ 'The differences between task start times obtained ' ...
, 'in two runs is less or equal than the value ' ...
, 'you specified.' ];
end 
end 

function res = checkNumOverruns( h, res )
if h.FirstRunBaseline
baseData = res.Run1Data;
compData = res.Run2Data;
else 
baseData = res.Run2Data;
compData = res.Run1Data;
end 
sameLength =  ...
isequal( length( compData.StartTimes ), length( baseData.StartTimes ) ) &&  ...
isequal( length( compData.EndTimes ), length( baseData.EndTimes ) );
if ~sameLength && ~h.Trim
res.Warnings( end  + 1 ).Type = 'DifferentResultLengths';
res.Warnings( end  ).Msg{ 1 } =  ...
[ 'Different number of recorded task start or task end ' ...
, 'instances obtained in two runs.' ];
end 
L2 = min( length( compData.EndTimes ), length( baseData.EndTimes ) );


compRunEnds = compData.EndTimes( 1:L2 );
baseRunEnds = baseData.EndTimes( 1:L2 );



blk = find_system( h.ModelName, 'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices, 'MaskType', 'Task Manager' );
assert( ~isempty( blk ), 'Task Manager not found in the model' );
allTaskData = get_param( blk{ 1 }, 'AllTaskData' );
dm = soc.internal.TaskManagerData( allTaskData, 'evaluate', h.ModelName );
taskData = dm.getTask( res.Task );
assert( isequal( taskData.taskType, 'Timer-driven' ),  ...
[ 'Task ', res.Task, ' is not Timer-driven' ] );
expEnds = ( 1:numel( compRunEnds ) ) * taskData.taskPeriod;

startIdxBase = [  ];
for i = 1:numel( baseRunEnds )
if ( expEnds( i ) < baseRunEnds( i ) )
startIdxBase = [ startIdxBase, i ];%#ok<AGROW>
end 
end 

startIdxComp = [  ];
for i = 1:numel( compRunEnds )
if ( expEnds( i ) < compRunEnds( i ) )
startIdxComp = [ startIdxComp, i ];%#ok<AGROW>
end 
end 

diffOverrunsIdx = union( setdiff( startIdxComp, startIdxBase ),  ...
setdiff( startIdxBase, startIdxComp ) );
res.Passed = ~any( diffOverrunsIdx );

if ~res.Passed
res.Violations( end  + 1 ).Type = 'NumOverruns';
res.Violations( end  ).Run2Data.StartTimes =  ...
res.Run2Data.StartTimes( diffOverrunsIdx );
res.Violations( end  ).Run1Data.StartTimes =  ...
res.Run1Data.StartTimes( diffOverrunsIdx );
res.Violations( end  ).Msg{ 1 } =  ...
'Recorded overruns obtained in two runs are different.';
res.Violations( end  ).Msg{ 2 } = [ 'Run # 1 had ', num2str( numel( startIdxBase ) ), ' overruns.' ];
res.Violations( end  ).Msg{ 3 } = [ 'Run # 2 had ', num2str( numel( startIdxComp ) ), ' overruns.' ];
else 
res.Messages{ end  + 1 } =  ...
'The number of overruns in two runs are the same.';
end 
end 

function plotTaskDurationViolations( h, results )
runName = [ h.ModelName, '_comparison' ];
if h.MaxDifferenceRelative, unit = '[%]';else , unit = '[s]';end 
for idx = 1:numel( results )
viewer( idx ) = h.createSignalViewer( results{ idx }.Task,  ...
[ 'TaskDurationViolations ', unit ], 'single' );%#ok<AGROW>
end 
h.startViewer( runName );
for idx = 1:numel( results )
thisResult = results{ idx };
violations = thisResult.Violations;
if ~isempty( violations )
if h.isRunVsRun(  )
if h.FirstRunBaseline
violBase = violations.Run1Data;
violComp = violations.Run2Data;
else 
violComp = thisResult.Run1Data.StartTimes;
violBase = thisResult.Run2Data.StartTimes;
end 
else 
violComp = thisResult.Run1Data;
violBase.Durations = h.BaseValue;
end 
sigTim = violComp.StartTimes;
sigVal = abs( violComp.Durations - violBase.Durations );
if h.MaxDifferenceRelative
sigVal = 100 * ( sigVal ./ violBase.Durations );
end 
else 
sigTim = thisResult.Run1Data.StartTimes;
sigVal = zeros( 1, numel( sigTim ) );
end 
for j = 1:numel( sigTim )
viewer( idx ).update( cast( sigVal( j ), 'single' ), int64( sigTim( j ) * 1e9 ) );
end 
viewer( idx ).clear(  );
end 
end 

function plotTaskInstanceViolations( h, results )
runName = [ h.ModelName, '_comparison' ];
for idx = 1:numel( results )
viewer( idx ) = h.createSignalViewer( results{ idx }.Task,  ...
'TaskInstanceViolations [s]', 'single' );%#ok<AGROW>
end 
h.startViewer( runName );
for idx = 1:numel( results )
thisResult = results{ idx };
violations = thisResult.Violations;
if ~isempty( violations )
if h.FirstRunBaseline
violBase = violations.Run1Data;
violComp = violations.Run2Data;
else 
violComp = thisResult.Run1Data;
violBase = thisResult.Run2Data;
end 
sigTim = violComp.StartTimes;
sigVal = abs( violComp.StartTimes - violBase.StartTimes );
if h.MaxDifferenceRelative
sigVal = 100 * ( sigVal ./ violBase.StartTimes );
end 
else 
sigTim = thisResult.Run1Data.StartTimes;
sigVal = zeros( 1, numel( sigTim ) );
end 
for j = 1:numel( sigTim )
viewer( idx ).update( cast( sigVal( j ), 'single' ), int64( sigTim( j ) * 1e9 ) );
end 
viewer( idx ).clear(  );
end 
end 

function plotNumOverrunsViolations( h, results )
runName = [ h.ModelName, '_comparison' ];
for idx = 1:numel( results )
viewer( idx ) = h.createSignalViewer( results{ idx }.Task,  ...
'OverrunViolations', 'int32' );%#ok<AGROW>
end 
h.startViewer( runName );
for idx = 1:numel( results )
thisResult = results{ idx };
violations = thisResult.Violations;
if ~isempty( violations )
if h.FirstRunBaseline
violComp = violations.Run2Data;
else 
violComp = violations.Run1Data;
end 
sigVal = ones( 1, numel( violComp.StartTimes ), 'int32' );
sigTim = violComp.StartTimes;
else 
sigTim = thisResult.Run1Data.StartTimes;
sigVal = zeros( 1, numel( sigTim ), 'int32' );
end 
for j = 1:numel( sigTim )
viewer( idx ).update( cast( sigVal( j ), 'int32' ), sigTim( j ) );
end 
viewer( idx ).clear(  );
end 
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpXf_2jS.p.
% Please follow local copyright laws when handling this file.

