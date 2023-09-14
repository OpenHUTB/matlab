classdef TrainingPlotter < nnet.internal.cnn.ui.TrainingPlotter

properties ( Access = private, Transient )
Label
Axes
Metrics
Throttle
IsWorker = true
end 

properties ( Access = private )
DataQueue
end 

properties ( SetAccess = private, Transient )
TrainingAxes
MaxIterations
MaxEpochs
StopReason
ExecutionEnvironmentInfo
end 

events 
UpdateTrainingPlot
end 

methods 
function self = TrainingPlotter( options )
R36
options.DataQueue( 1, 1 );
end 

self.IsWorker = false;
if isfield( options, "DataQueue" )
self.DataQueue = options.DataQueue;
self.DataQueue.afterEach( @self.receiveFromWorker );
end 
self.Throttle = tic(  );
self.reset(  );
end 

function delete( self )
if ~self.IsWorker
delete( self.DataQueue );
delete( self.TrainingAxes );
end 
end 

function receiveFromWorker( self, message )
self.( message{ 1 } )( message{ 2:end  } );
end 

function reset( self )
self.TrainingAxes = uigridlayout( 'Parent', [  ], 'RowHeight', { 'fit' }, 'ColumnWidth', { '1x' } );
end 

function out = detachTrainingAxes( self )
out = self.TrainingAxes;
self.TrainingAxes = [  ];
end 

function setTitle( self, title )
if self.IsWorker
self.DataQueue.send( { 'setTitle', title } );
return ;
end 
label = uilabel( 'Parent', self.TrainingAxes, 'Text', title, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'center' );
label.Layout.Row = 1;
end 

function configure( self, plotConfig )



self.ExecutionEnvironmentInfo = struct( 'ExecutionEnvironment', plotConfig.ExecutionEnvironment,  ...
'UseParallel', plotConfig.UseParallel );
epochInfo = nnet.internal.cnn.ui.EpochInfo(  ...
plotConfig.TrainingOptions.MaxEpochs,  ...
plotConfig.NumObservations,  ...
plotConfig.TrainingOptions.MiniBatchSize );
self.StopReason = [  ];

if plotConfig.HasVariableNumItersPerEpoch
self.MaxIterations = inf;
self.MaxEpochs = plotConfig.TrainingOptions.MaxEpochs;
else 
self.MaxIterations = min( epochInfo.NumIters, inf );
self.MaxEpochs = plotConfig.TrainingOptions.MaxEpochs;
end 

if self.IsWorker
self.DataQueue.send( { 'configure', plotConfig } );
return ;
end 

if plotConfig.HasVariableNumItersPerEpoch
epochDisplayer = nnet.internal.cnn.ui.axes.EpochDisplayHider(  );
else 
epochDisplayer = nnet.internal.cnn.ui.axes.EpochAxesDisplayer(  );
end 

axesConfiguration = plotConfig.AxesConfiguration;
numAxes = axesConfiguration.NumAxes;
axes = cell( 1, numAxes );
metrics = cell( 1, numAxes );
rowHeight = cell( 1, numAxes + 1 );
rowHeight{ 1 } = 'fit';
for k = 1:numAxes
axesFactory = nnet.internal.cnn.ui.factory.UIFigureGenericAxesFactory( axesConfiguration.CellArrayOfAxesProperties{ k } );
rowHeight{ k + 1 } = [ num2str( axesFactory.AxesProperties.SizeFraction ), 'x' ];
[ axes{ k }, metrics{ k } ] = axesFactory.createAxesAndMetrics( epochInfo, epochDisplayer );
axes{ k }.Panel.Parent = self.TrainingAxes;
axes{ k }.Panel.Layout.Row = k + 1;
end 
self.TrainingAxes.RowHeight = rowHeight;
self.Axes = axes;
self.Metrics = [ metrics{ : } ];
end 

function showPreprocessingStage( ~, ~ )
end 

function showTrainingStage( ~, ~ )
end 

function updatePlot( self, infoStruct )
if self.IsWorker
self.DataQueue.send( { 'updatePlot', infoStruct } );
return ;
end 

cellfun( @( m )m.update( infoStruct ), self.Metrics );
if toc( self.Throttle ) > experiments.internal.View.feature.trainingPlotterThrottleRate
self.Throttle = tic(  );
cellfun( @update, self.Axes );
drawnow limitrate;
if event.hasListener( self, 'UpdateTrainingPlot' )
self.notify( 'UpdateTrainingPlot' );
end 
end 
end 

function updatePlotForLastIteration( self, infoStruct )
if self.IsWorker
self.DataQueue.send( { 'updatePlotForLastIteration', infoStruct } );
return ;
end 
cellfun( @( m )m.updateForLastIteration( infoStruct ), self.Metrics );
cellfun( @update, self.Axes );
drawnow(  );
end 

function showPostTrainingStage( self, ~, infoStruct, stopReason )
self.StopReason = stopReason;
if self.IsWorker
self.DataQueue.send( { 'showPostTrainingStage', [  ], infoStruct, self.StopReason } );
return ;
end 
cellfun( @( m )m.updatePostTraining( infoStruct ), self.Metrics );
cellfun( @update, self.Axes );
cellfun( @finalize, self.Axes );
drawnow(  );
end 

function showPlotError( ~, ~ )
end 

function finalizePlot( ~, ~ )
end 

function requestStopTraining( self )
self.notify( 'StopTrainingRequested' );
end 
end 
end 



