function [ runId, status, result ] = runTargetOnSlProcess( runId, cmd, p )


R36
runId
cmd( 1, : )char
p( 1, 1 )slprocess.Process = slprocess.Process
end 

simulink.rapidaccelerator.internal.setTargetLibPathOnSlProcess( p );
p.run( cmd );
status = p.Status;
result = p.Result;
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpAg_wq4.p.
% Please follow local copyright laws when handling this file.

