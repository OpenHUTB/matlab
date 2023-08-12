



function slssdisconnectWorkerConnections( clientId )
p = gcp( 'nocreate' );
if ~isempty( p )
parfevalOnAll( @localDisconnect, 0, clientId );
end 
end 

function localDisconnect( clientId )
instance = MultiSim.internal.WorkerTempStorage.getInstance(  );
connectionIdsMap = instance.get( 'slssConnectionIdsMap' );

if isKey( connectionIdsMap, clientId )
id = connectionIdsMap( clientId );
mgr = slss.Manager;
mgr.disconnect( id );
connectionIdsMap.remove( clientId );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpzbsHpD.p.
% Please follow local copyright laws when handling this file.

