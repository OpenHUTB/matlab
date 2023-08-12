function runFutures = runTargetsOnThreadPool( runCmd, buildData, tpoolMgr )


R36
runCmd( 1, : )cell
buildData
tpoolMgr( 1, 1 )simulink.rapidaccelerator.internal.ThreadPoolManager
end 

assert( isa( buildData.multiSimInfo.dataQueue, 'parallel.pool.DataQueue' ) );
assert( isa( buildData.multiSimInfo.verboseQueue, 'parallel.pool.DataQueue' ) );
numRuns = numel( runCmd );

buildData.multiSimInfo.verboseQueue.send(  ...
sprintf( '### %6.2fs :: Starting %i processes on ThreadPool.',  ...
etime( clock, buildData.startTime ), numRuns ) );

runFutures( 1:numRuns ) = parallel.FevalFuture;
for runIdx = 1:numRuns
runFutures( runIdx ) = tpoolMgr.ThreadPool.parfeval(  ...
@simulink.rapidaccelerator.internal.runTargetOnSlProcess,  ...
3,  ...
buildData.multiSimInfo.runInfo( runIdx ).RunId,  ...
runCmd{ runIdx } );
end 

end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmp1APneX.p.
% Please follow local copyright laws when handling this file.

