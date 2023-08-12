function attachFilesToPool( pool, files )




R36
pool( 1, 1 )parallel.Pool
files string
end 

warningId = "parallel:lang:pool:IgnoringAlreadyAttachedFiles";
warningState = warning( 'off', warningId );
warnCleanupObj = onCleanup( @(  )warning( warningState ) );
addAttachedFiles( pool, files );

end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmp8kJzPL.p.
% Please follow local copyright laws when handling this file.

