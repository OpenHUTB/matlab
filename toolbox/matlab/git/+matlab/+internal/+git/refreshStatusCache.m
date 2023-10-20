function varargout = refreshStatusCache( repo, callable )




R36
repo( 1, 1 )matlab.git.GitRepository
callable( 1, 1 )function_handle
end 

import matlab.internal.lang.capability.Capability

if ~matlab.internal.git.isJavaUI
try 
[ varargout{ 1:nargout } ] = callable(  );
catch ME
ME.throwAsCaller(  );
end 
return 
end 

cmStatusCacheProvider = com.mathworks.cmlink.management.pool.shared.SingletonPooledCmStatusCacheProvider.getInstance(  );
applicationInteractor = com.mathworks.sourcecontrol.MLApplicationInteractor(  );
cmStatusCache = cmStatusCacheProvider.provideCacheFor( applicationInteractor, java.io.File( repo.WorkingFolder ), false );
cmAdapter = cmStatusCache.getAdapter(  );
if ~isempty( cmAdapter )
disabledChangeDetector = i_disabledChangeDetector( cmAdapter );
cleanupObj = onCleanup( @(  )disabledChangeDetector.close(  ) );
end 

try 
[ varargout{ 1:nargout } ] = callable(  );
catch ME
ME.throwAsCaller(  );
end 

cmStatusCache.refresh(  );
if ~isempty( cmAdapter )
updateBranches( cmAdapter );
end 
end 
function gitAdapter = getGitAdapter( cmAdapter )
classLoader = java.lang.ClassLoader.getSystemClassLoader(  );
gitAdapterClass = java.lang.Class.forName( com.mathworks.cmlink.implementations.git.GitAdapter.class, true, classLoader );
gitAdapter = cmAdapter.extractDelegate( gitAdapterClass );
end 
function updateBranches( cmAdapter )
gitAdapter = getGitAdapter( cmAdapter );
gitActionSet = gitAdapter.getGitActionSet(  );
headChangeBroadcaseter = gitActionSet.getHeadChangeBroadcaster(  );
headChangeBroadcaseter.fireHeadChangeEvent(  );
end 
function disabledChangeDetector = i_disabledChangeDetector( cmAdapter )
gitAdapter = getGitAdapter( cmAdapter );
disabledChangeDetector = gitAdapter.getGitActionSet(  ).getexternalChangeDetector(  ).disable(  );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpqCxqeh.p.
% Please follow local copyright laws when handling this file.

