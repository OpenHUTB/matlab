function isRunning = pmsl_ismodelrunning( hdl )






bd = pmsl_bdroot( hdl );

runningStatii = {  ...
'running',  ...
'paused',  ...
'compiled',  ...
'restarting',  ...
'terminating',  ...
'external' ...
 };

status = get_param( bd, 'SimulationStatus' );
isRunningStatus = any( strcmpi( status, runningStatii ) );

isExtModeConnected = strcmpi( get_param( bd, 'extmodeconnected' ), 'on' );

isRunning = isRunningStatus || isExtModeConnected;

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpVXWiyv.p.
% Please follow local copyright laws when handling this file.

