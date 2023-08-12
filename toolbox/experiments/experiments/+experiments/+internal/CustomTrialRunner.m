classdef CustomTrialRunner < experiments.internal.AbstractTrialRunner




properties 
trainingFcn

expmgr


Throttle
TrainingAxes
TitleLabel
XLabel
LabelMap
doPlotInit
Metrics
customMetricData
msg
msgTimer
runningMonitorListener
sendPendingMsg

Factory
Model
MultiAxesView
end 

events 
UpdateTrainingPlot
end 

methods 
function obj = CustomTrialRunner( dataQueue, execInfo, rngState, paramStruct, snapshotDir, trainingFcn )

superClsArgs.dataQueue = dataQueue;
superClsArgs.stopDataQueue = [  ];
superClsArgs.execInfo = execInfo;
superClsArgs.curRowData = [  ];
superClsArgs.rngState = rngState;
superClsArgs.paramStruct = paramStruct;
superClsArgs.snapshotDir = snapshotDir;

obj@experiments.internal.AbstractTrialRunner( superClsArgs );

obj.trainingFcn = trainingFcn;
obj.runningMonitorListener = false;
obj.sendPendingMsg = false;
obj.Factory = experiments.internal.ExpMonitorFactory(  );

obj.TrainingAxes = uigridlayout( 'Parent', [  ],  ...
'RowHeight', { 'fit', '1x' },  ...
'ColumnWidth', { '1x' } );

obj.TitleLabel = uilabel( 'Parent', obj.TrainingAxes,  ...
'Text', execInfo.trainingPlotTitle,  ...
'FontWeight', 'bold',  ...
'HorizontalAlignment', 'center',  ...
'VerticalAlignment', 'center' );
obj.TitleLabel.Layout.Row = 1;

obj.XLabel = '';
obj.LabelMap = containers.Map( 'KeyType', 'char', 'ValueType', 'any' );
obj.doPlotInit = true;
obj.createMesssage(  );
obj.msgTimer = [  ];
obj.customMetricData = [  ];
end 

function createMesssage( this )
this.msg = struct(  );
this.msg.InfoValue = struct(  );
this.msg.MetricsValue = struct(  );
this.msg.PlotValue = struct(  );
this.msg.subPlots = cell( 0, 1 );
this.msg.newInfo = [  ];
this.msg.newMetrics = [  ];
end 

function createEMInterface( this )
this.expmgr = experiments.Monitor(  );
if ( this.execInfo.isBayesOptExp )
this.expmgr.optimizableMetricName = this.execInfo.OptimizableMetricData{ 1 };
end 
this.expmgr.addlistener( 'Progress', 'PostSet', @( ~, ~ )this.onProgressPostSet(  ) );
this.expmgr.addlistener( 'Status', 'PostSet', @( ~, ~ )this.onStatusPostSet(  ) );
this.expmgr.addlistener( 'Metrics', 'PostSet', @( ~, ~ )this.onMetricsPostSet(  ) );
this.expmgr.addlistener( 'Info', 'PostSet', @( ~, ~ )this.onInfoPostSet(  ) );
this.expmgr.addlistener( 'MetricsUpdate', @( ~, evtData )this.onMetricsUpdate( evtData.data ) );
this.expmgr.addlistener( 'InfoUpdate', @( ~, evtData )this.onInfoUpdate( evtData.data ) );
this.expmgr.addlistener( 'XLabel', 'PostSet', @( ~, ~ )this.onXLabelPostSet(  ) );
this.expmgr.addlistener( 'GroupPlot', @( ~, evtData )this.onGroupPlot( evtData.data ) );
this.expmgr.addlistener( 'ReadStop', @( ~, evtData )this.onReadStopTrial(  ) );
end 

function panel = getPanel( this )
panel = this.TrainingAxes;
end 

function out = detachTrainingAxes( this )
out = this.TrainingAxes;
this.TrainingAxes = [  ];
end 

function setStopOnMonitor( this, val )
R36
this
val = true
end 
this.expmgr.setStopFlag( val );
end 

function output = executeTrainingFcn( this, trialDir )

if this.isParallel
loc_snapshotDir = getAttachedFilesFolder( this.snapshotDir );
trialDir = tempname;
else 
loc_snapshotDir = this.snapshotDir;
end 
if ~isfolder( trialDir )
mkdir( trialDir );
end 
oldDir = cd( trialDir );
oldPath = addpath( genpath( loc_snapshotDir ) );
cleanupPath = onCleanup( @(  )resetDirAndPath( oldDir, oldPath ) );

warnState = warning( 'off', 'experiments:customExperiment:unsupportedMethodPlot' );
cleanupWarning = onCleanup( @(  )warning( warnState ) );
function resetDirAndPath( oldDir, oldPath )
path( oldPath );
cd( oldDir );
end 
this.createEMInterface(  );
function keyUpdateFcn( valueStore, key )
if strcmp( key, "Stop" )
val = valueStore( key );
if ~isempty( val ) && ( val == 0 || val == this.execInfo.trialID )
this.setStopOnMonitor(  );
end 
end 
end 
function cleanupStoreUpdateFcn(  )
store = getCurrentValueStore(  );
store.KeyUpdatedFcn = [  ];
end 
if this.isParallel
store = getCurrentValueStore(  );
if ~isempty( store )


store.KeyUpdatedFcn = @keyUpdateFcn;
cleanupStore = onCleanup( @(  )cleanupStoreUpdateFcn(  ) );
end 
end 
output = feval( this.trainingFcn, this.paramStruct, this.expmgr );
end 

function result = runTrialInParallel( this, trialDir )
result = NaN;
try 
this.sendStopDataQueue(  );


msgRunning.ID = 'Running';
msgRunning.trialStartTime = struct( 'startTime', experiments.internal.getCurrentTimeString(  ), 'completionTime', '' );
this.sendMessage( { 'UpdateResult',  ...
this.execInfo.runID,  ...
this.execInfo.trialID,  ...
msgRunning } );

rng( this.rngState );
output = this.executeTrainingFcn( trialDir );

if ~this.stopTrial
msgFinal.ID = 'Complete';
elseif this.execInfo.isBayesOptExp && this.stopTrial
msgFinal.ID = 'Canceled';
elseif this.stopTrial
msgFinal.ID = 'Stopped';
end 

msgFinal.paramList = fieldnames( this.paramStruct );
msgFinal.output = output;


if this.execInfo.isBayesOptExp && isempty( this.customMetricData )
error( message( 'experiments:customExperiment:NoMetricValueToOptimize', this.execInfo.OptimizableMetricData{ 1 } ) );
elseif this.execInfo.isBayesOptExp
result = this.customMetricData;
if strcmp( this.execInfo.OptimizableMetricData{ 2 }, 'Maximize' )
result =  - result;
end 
end 
catch ME1
if this.isParallel && strcmp( ME1.identifier, 'parallel:lang:pool:RunOnLabs' )



METop = MException( message( 'experiments:customExperiment:NoParallelPool' ) );
ME1 = METop.addCause( ME1 );
ME = experiments.internal.ExperimentException( ME1 );
snapshotPath = getAttachedFilesFolder(  );
report = experiments.internal.getErrorReportWithCauseCallStacks( ME,  ...
'SnapshotPath', snapshotPath,  ...
'RunID', this.execInfo.runID );
else 
ME = experiments.internal.ExperimentException( ME1 );
report = this.getErrorReport( ME );
end 

msgFinal.ID = 'Error';
msgFinal.errorText = report;
end 
if ~isempty( this.msgTimer )
this.msgTimer.stop(  );
end 
this.sendMessage( { 'MessageQue',  ...
this.execInfo.runID,  ...
this.execInfo.trialID,  ...
this.msg } );
this.sendMessage( { 'UpdateResult',  ...
this.execInfo.runID,  ...
this.execInfo.trialID,  ...
msgFinal } );
end 

function initPlot( this )
if this.doPlotInit
this.Model = this.Factory.createMonitorModel(  );
this.MultiAxesView = this.Factory.createMultiAxesView( this.TrainingAxes, this.Model );
this.doPlotInit = false;
this.Throttle = tic(  );
end 
end 

function addMetrics( this )
this.Model.addMetrics( this.Metrics );
end 

function updateXLabel( this )
this.Model.XLabel = this.XLabel;
end 

function groupPlots( this )
ks = this.LabelMap.keys(  );
for i = 1:this.LabelMap.Count
this.Model.groupSubPlot( string( ks{ i } ), string( this.LabelMap( ks{ i } ) ) );
end 
end 

function updatePlot( this, val )
f = fieldnames( val );
for i = 1:length( f )
name = f{ i };
n = size( val.( name ), 1 );
for j = 1:n
this.Model.recordMetrics( val.( name )( j, 1 ), string( name ), val.( name )( j, 2 ), EnableLogging = false );
end 
end 
if toc( this.Throttle ) > experiments.internal.View.feature.trainingPlotterThrottleRate
this.Throttle = tic(  );
drawnow limitrate;
if this.execInfo.runBatch
this.notify( 'UpdateTrainingPlot' );
end 
end 
end 

function sendQuedMsg( this, ~, ~ )
if this.runningMonitorListener



this.sendPendingMsg = true;
return ;
end 
this.sendMessage( { 'MessageQue',  ...
this.execInfo.runID,  ...
this.execInfo.trialID,  ...
this.msg } );
this.createMesssage(  );
end 

function clearTimer( this, ~, ~ )
delete( this.msgTimer );
this.msgTimer = [  ];
end 

function startMsgTimer( this )
this.runningMonitorListener = false;
if this.sendPendingMsg



this.sendPendingMsg = false;
this.sendQuedMsg(  );
end 
if isempty( this.msgTimer )
this.msgTimer = timer( 'StartDelay', 1,  ...
'ExecutionMode', 'singleShot' );
this.msgTimer.TimerFcn = @this.sendQuedMsg;
this.msgTimer.StopFcn = @this.clearTimer;
this.msgTimer.start(  );
end 
end 
end 


methods 

function onMetricsUpdate( this, data )
this.runningMonitorListener = true;
cleanup = onCleanup( @(  )this.startMsgTimer(  ) );
index = data{ 1 };
fnames = fieldnames( data{ 2 } );
for i = 1:length( fnames )
field = fnames{ i };
if isfield( this.msg.PlotValue, field )
v = [ this.msg.PlotValue.( field );index, data{ 2 }.( field ) ];
else 
v = [ index, data{ 2 }.( field ) ];
end 
this.msg.PlotValue.( field ) = v;
this.msg.MetricsValue.( field ) = data{ 2 }.( field );
if ( this.execInfo.isBayesOptExp && strcmp( this.execInfo.OptimizableMetricData{ 1 }, field ) )
this.customMetricData = this.msg.MetricsValue.( field );
end 
end 
end 

function onInfoUpdate( this, data )
this.runningMonitorListener = true;
cleanup = onCleanup( @(  )this.startMsgTimer(  ) );
fnames = fieldnames( data{ 1 } );
for i = 1:length( fnames )
field = fnames{ i };
this.msg.InfoValue.( field ) = data{ 1 }.( field );
end 
end 

function onGroupPlot( this, data )
this.runningMonitorListener = true;
cleanup = onCleanup( @(  )this.startMsgTimer(  ) );
this.msg.subPlots{ end  + 1 } = data;
end 

function onProgressPostSet( this )
this.runningMonitorListener = true;
cleanup = onCleanup( @(  )this.startMsgTimer(  ) );
this.msg.Progress = this.expmgr.Progress;
end 

function onXLabelPostSet( this )
this.runningMonitorListener = true;
cleanup = onCleanup( @(  )this.startMsgTimer(  ) );
this.msg.XLabel = this.expmgr.XLabel;
end 

function onStatusPostSet( this )
this.runningMonitorListener = true;
cleanup = onCleanup( @(  )this.startMsgTimer(  ) );
this.msg.UserStatus = this.expmgr.Status;
end 

function onInfoPostSet( this )
this.runningMonitorListener = true;
cleanup = onCleanup( @(  )this.startMsgTimer(  ) );
this.msg.newInfo = this.expmgr.Info;
end 

function onMetricsPostSet( this )
this.runningMonitorListener = true;
cleanup = onCleanup( @(  )this.startMsgTimer(  ) );
this.msg.newMetrics = this.expmgr.Metrics;
end 

function onReadStopTrial( this )


drawnow;
if this.isParallel
[ ~, val ] = this.stopDataQueue.poll( 0 );
else 
val = this.stopFunction(  );
end 
this.stopTrial = val;
this.expmgr.setStopFlag( val );
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp6pePRt.p.
% Please follow local copyright laws when handling this file.

