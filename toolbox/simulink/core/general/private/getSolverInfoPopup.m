function result = getSolverInfoPopup(  )

runStatus = '0';
simStatus = get_param( bdroot, 'SimulationStatus' );
if ( or( strcmp( simStatus, 'paused' ), strcmp( simStatus, 'running' ) ) )
runStatus = '1';
end 
fastRestart = '0';
if strcmp( get_param( bdroot, 'FastRestart' ), 'on' )
fastRestart = '1';
end 
steadyStateSim = '0';
if strcmp( get_param( bdroot, 'EnableSteadyStateSolver' ), 'on' )
steadyStateSim = '1';
end 
result = { runStatus, fastRestart, steadyStateSim };
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmp90ssuN.p.
% Please follow local copyright laws when handling this file.

