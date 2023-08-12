

function dq = slssSetupDataQueue( modelName, clientId, fh )

dq = parallel.internal.pool.DataQueue;
dq.UseWhenMatlabReady = false;
dq.afterEach( fh );
parfevalOnAll( @localSetupConnection, 1, modelName, clientId, dq );
end 

function id = localSetupConnection( modelName, clientId, dq )
mgr = slss.Manager;
id = mgr.connect( @dq.send, modelName );
instance = MultiSim.internal.WorkerTempStorage.getInstance(  );
connectionIdsMap = instance.get( 'slssConnectionIdsMap' );
connectionIdsMap( clientId ) = id;%#ok<NASGU>
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpXD9SWd.p.
% Please follow local copyright laws when handling this file.

