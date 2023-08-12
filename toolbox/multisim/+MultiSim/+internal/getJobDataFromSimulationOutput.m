function jobData = getJobDataFromSimulationOutput( simOuts )





R36
simOuts Simulink.SimulationOutput{ mustBeNonempty }
end 


persistent mf0Model
mf0Model = mf.zero.Model;

jobData = simulink.simmanager.mm.Job( mf0Model );





startTime = simOuts( 1 ).SimulationMetadata.TimingInfo.WallClockTimestampStart;
if ~isempty( startTime )
jobData.StartTime = datenum( startTime );
jobData.FinishTime = datenum( simOuts( end  ).SimulationMetadata.TimingInfo.WallClockTimestampStop );
end 




jobData.NumWorkers =  - 1;


for i = 1:numel( simOuts )
simulationRun = simulink.simmanager.mm.SimulationRun( mf0Model );
simulationRun.RunId = i;
[ statusString, state ] = getStatusStringAndState( simOuts( i ).SimulationMetadata );
simulationRun.StatusString = statusString;
simulationRun.State = state;
simulationRun.Progress = 100;
simulationRun.SimElapsedWallTime = simOuts( i ).SimulationMetadata.TimingInfo.TotalElapsedWallTime;

jobData.SimulationRuns.add( simulationRun );
end 
end 

function [ statusString, state ] = getStatusStringAndState( simMetadata )
R36
simMetadata( 1, 1 )Simulink.SimulationMetadata
end 



statusString = MultiSim.JobStatusDB.CompletedMsg;
state = statusString;
execInfo = simMetadata.ExecutionInfo;
if ~isempty( execInfo.ErrorDiagnostic )
switch execInfo.ErrorDiagnostic.Diagnostic( 1 ).identifier
case 'Simulink:Commands:SimAborted'
statusString = MultiSim.JobStatusDB.AbortedMsg;
state = statusString;

otherwise 
statusString = message( 'Simulink:MultiSim:CompletedWithErrors' ).getString(  );
state = MultiSim.JobStatusDB.ErrorsMsg;
end 
elseif ~isempty( execInfo.WarningDiagnostics )
statusString = MultiSim.JobStatusDB.CompletedWithWarningsMsg;
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpj5FTS_.p.
% Please follow local copyright laws when handling this file.

