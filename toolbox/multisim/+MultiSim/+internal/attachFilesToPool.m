function attachFilesToPool( pool, files )

arguments
    pool( 1, 1 )parallel.Pool
    files string
end

warningId = "parallel:lang:pool:IgnoringAlreadyAttachedFiles";
warningState = warning( 'off', warningId );
warnCleanupObj = onCleanup( @(  )warning( warningState ) );
addAttachedFiles( pool, files );

end
