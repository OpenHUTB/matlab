





classdef SimulationRunnerSerial < MultiSim.internal.SimulationRunner
properties ( Transient = true )
OldFastRestart
end 

properties ( SetAccess = protected )
SingleSimOutputType = Simulink.SimulationOutput
end 

properties ( Constant )
DefaultConfig = MultiSim.internal.SimulationRunnerSerialConfig
end 

properties ( SetAccess = protected, Hidden = true )
MultiSimRunningMessage = message( 'Simulink:Commands:MultiSimRunningSim' )
end 

properties ( Access = private )
FastRestartSignalLoggingHandler
end 

methods 
function obj = SimulationRunnerSerial( simMgr, namedargs )
R36
simMgr( 1, 1 )Simulink.SimulationManager
namedargs.Config( 1, 1 )MultiSim.internal.SimulationRunnerSerialConfig = MultiSim.internal.SimulationRunnerSerial.DefaultConfig
end 

namedargsCell = namedargs2cell( namedargs );
obj = obj@MultiSim.internal.SimulationRunner( simMgr, namedargsCell{ : } );
obj.OldFastRestart = containers.Map;
obj.OldDLO = containers.Map;
obj.OldDirtyFlag = containers.Map;
end 
end 


methods 
function actualSimulationInputs = setup( obj, actualSimulationInputs )
obj.CancelRequested = false;

if obj.Options.UseFastRestart
obj.cacheFastRestartState( actualSimulationInputs );
obj.FastRestartSignalLoggingHandler = MultiSim.internal.FastRestartSignalLoggingHandler( actualSimulationInputs );
end 



obj.runSetupFcn(  );







if ~obj.Options.AllowMultipleModels
obj.doParallelBuild(  );
end 
end 

function simInput = setupLogging( obj, simInput )













modelName = simInput.getModelNameForApply(  );
if obj.Options.UseFastRestart
if ~isKey( obj.OldDLO, modelName )
obj.OldDLO( modelName ) = get_param( modelName, 'DataLoggingOverride' );
obj.OldDirtyFlag( modelName ) = get_param( modelName', 'Dirty' );
end 
simInput = obj.FastRestartSignalLoggingHandler.setupLoggingForFastRestart( simInput );
end 
simInput = obj.makeLTFFileNamesUnique( simInput, obj.WorkingDir );
simInput = SlCov.CoverageAPI.setupSimInputForCoverage( simInput, obj.WorkingDir, true, true );
end 

function cleanup( obj )
obj.runCleanupFcn(  );

if obj.Options.UseFastRestart
obj.restoreFastRestartState(  );
delete( obj.FastRestartSignalLoggingHandler );
obj.restoreDataLoggingOverrideAndDirtyFlag(  );
end 
end 

function cancel( obj, ~ )


obj.CancelRequested = true;


if bdIsLoaded( obj.ModelName )
set_param( obj.ModelToApply, 'SimulationCommand', 'stop' );
end 
end 

function out = executeImpl( obj, fh, simIns )
obj.NumSims = numel( simIns );
obj.setupSims( simIns );
out = obj.preAllocateOutputs( simIns );
eventData = MultiSim.internal.SimulationRunnerEventData( [  ] );
notify( obj, 'AllSimulationsQueued', eventData );

for i = 1:obj.NumSims
if obj.CancelRequested
return ;
end 
simInput = simIns( i );

simInput = simInput.addHiddenModelParameter( 'CaptureErrors', 'on' );

runNumStr = num2str( simInput.RunId );
simInput = simInput.addHiddenModelParameter( 'ConcurrencyResolvingToFileSuffix', [ '_', runNumStr ] );





simInput.UsingManager = true;

simInput.LoggingSetupFcn = @obj.setupLogging;






out( i ) = obj.executeImplSingle( fh, simInput );
end 
end 

function dispatchRunsIfNeeded( ~ )
end 

function assignOutputsOnSimManager( ~ )


end 
end 

methods ( Access = private )
function simOut = executeImplSingle( obj, fh, simInput )




forRunAll = obj.ForRunAll;
studioBlocker = [  ];
if ~forRunAll
studioBlocker = obj.Config.StudioBlockerCreator(  );
end 



delete( studioBlocker );
simInfo = Simulink.Simulation.internal.SimInfo;
simInfo.UseFastRestart = obj.Options.UseFastRestart;
simInput.SimInfo = simInfo;
simOut = MultiSim.internal.runSingleSim( fh, simInput );



if ~forRunAll
studioBlocker = obj.Config.StudioBlockerCreator(  );%#ok<NASGU>
end 


obj.notifySimulationFinishedRunning( simInput.RunId );


evtData = MultiSim.internal.SimulationOutputAvailableEventData( simOut, simInput.RunId );
obj.notify( 'SimulationOutputAvailable', evtData );



if obj.CancelRequested || obj.wasStopRequested( simOut )

evtData = MultiSim.internal.SimulationAbortedEventData( true, simInput.RunId:obj.NumSims );
obj.notify( 'SimulationAborted', evtData );

if ~obj.CancelRequested
err = MException( message( 'Simulink:Commands:SimAborted' ) );
msld = MSLDiagnostic( err );
msld.reportAsError( obj.ModelName );
end 
end 
end 

function cacheFastRestartState( obj, simInputs )
uniqueModels = obj.getUniqueModels( simInputs );
for model = uniqueModels
if bdIsLoaded( model )
obj.OldFastRestart( model ) = get_param( model, 'FastRestart' );
else 
obj.OldFastRestart( model ) = 'off';
end 
end 
end 

function restoreFastRestartState( obj )
allModels = string( keys( obj.OldFastRestart ) );
for model = allModels
if bdIsLoaded( model )
set_param( model, 'FastRestart', obj.OldFastRestart( model ) );
end 
end 
end 

function restoreDataLoggingOverrideAndDirtyFlag( obj )
allModels = string( keys( obj.OldDLO ) );
for model = allModels
if bdIsLoaded( model )
set_param( model, "DataLoggingOverride", obj.OldDLO( model ) );
set_param( model, "Dirty", obj.OldDirtyFlag( model ) );
end 
end 
end 
end 

methods ( Static, Access = private )
function uniqueModels = getUniqueModels( simInputs )
modelNames = arrayfun( @( simIn )simIn.getModelNameForApply(  ), simInputs, 'UniformOutput', false );
modelNames = cellfun( @( x )convertStringsToChars( x ), modelNames, 'UniformOutput', false );

uniqueModels = string( unique( modelNames ) );
end 
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpdviIKT.p.
% Please follow local copyright laws when handling this file.

