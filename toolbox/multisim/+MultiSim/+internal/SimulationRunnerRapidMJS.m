







classdef SimulationRunnerRapidMJS < MultiSim.internal.SimulationRunnerParallelMJS ...
 & MultiSim.internal.SimulationRunnerRapidBase
methods 
function obj = SimulationRunnerRapidMJS( simMgr, pool )
R36
simMgr( 1, 1 )Simulink.SimulationManager
pool( 1, 1 )parallel.Pool = gcp
end 
obj@MultiSim.internal.SimulationRunnerRapidBase( simMgr, pool );
obj@MultiSim.internal.SimulationRunnerParallelMJS( simMgr, pool );
end 
end 

methods ( Access = protected )
function simInputs = setupLogging( obj, simInputs )

simInputs = obj.setupToFileLogging( simInputs );

simInputs = obj.setupLoggingToFile( simInputs );
end 
end 

methods ( Access = private )
function simInputs = setupToFileLogging( obj, simInputs )
simInp = simInputs( 1 );

toFileBlockPaths = obj.ToFileBlockPathsMap( simInp.ModelName );
for idx = 1:numel( toFileBlockPaths )
currName = simInp.getToFileName( toFileBlockPaths{ idx } );
fileParts = obj.LoggingFileToFilepartsMap( currName );
origPath = fileParts.Dir;
name = fileParts.FileName;













end 
end 

function simInputs = setupLoggingToFile( obj, simInputs )
simInp = simInputs( 1 );

currName = simInp.getLTFName(  );
if ~obj.LoggingFileToFilepartsMap.isKey( currName )
return ;
end 

fileParts = obj.LoggingFileToFilepartsMap( currName );
origPath = fileParts.Dir;
name = fileParts.FileName;












end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpC2Wz2f.p.
% Please follow local copyright laws when handling this file.

