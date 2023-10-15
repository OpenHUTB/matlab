function [ runId, status, result ] = runTargetOnSlProcess( runId, cmd, p )

arguments
    runId
    cmd( 1, : )char
    p( 1, 1 )slprocess.Process = slprocess.Process
end

simulink.rapidaccelerator.internal.setTargetLibPathOnSlProcess( p );
p.run( cmd );
status = p.Status;
result = p.Result;
end
