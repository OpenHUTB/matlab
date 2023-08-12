







classdef SimulationRunnerRapidThreads < MultiSim.internal.SimulationRunnerRapidBase

methods 
function obj = SimulationRunnerRapidThreads( simMgr, pool )
R36
simMgr( 1, 1 )Simulink.SimulationManager
pool( 1, 1 )parallel.Pool = gcp
end 
obj@MultiSim.internal.SimulationRunnerRapidBase( simMgr, pool );
end 

function actualSimulationInputs = setup( obj, actualSimulationInputs )
load_system( obj.ModelName );

obj.CancelRequested = false;

obj.runSetupFcn(  );

obj.doParallelBuild(  );
end 

function cleanup( obj )
obj.runCleanupFcn(  );
end 

function cancel( obj, ~ )
obj.CancelRequested = true;
end 

function createExecutionArgs( ~, ~, ~ )
end 

function addDataToSimFuture( ~, ~, ~ )
end 

function executeFcnHandle( ~ )
end 
end 

methods ( Access = protected )
function simInputs = setupLogging( obj, simInputs )
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpiM_DFu.p.
% Please follow local copyright laws when handling this file.

