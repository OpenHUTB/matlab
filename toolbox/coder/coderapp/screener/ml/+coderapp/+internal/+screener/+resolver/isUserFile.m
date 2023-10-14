function result = isUserFile( filePath, aUseCachedSupportPackageRoot )
arguments
    filePath( 1, 1 )string
    aUseCachedSupportPackageRoot( 1, 1 )logical = false
end
if coderapp.internal.screener.resolver.isBuiltIn( filePath )
    result = false;
    return ;
end
if aUseCachedSupportPackageRoot
    supportPkgRoot = coderapp.internal.screener.cache.getSupportPackageRoot;
else
    supportPkgRoot = matlabshared.supportpkg.getSupportPackageRoot;
end
isSupportPkgFunction = ~isempty( supportPkgRoot ) && contains( filePath, supportPkgRoot );

result = ~isMathWorksFunction( filePath ) && ~isSupportPkgFunction;
end


function result = isMathWorksFunction( aFilePath )
for dir = getCachedMATLABSourceCodeDirs
    if contains( aFilePath, dir )
        result = true;
        return ;
    end
end
result = false;
end

function result = getCachedMATLABSourceCodeDirs
persistent cache;
if isempty( cache )
    dirs = coderapp.internal.util.foundation.getMATLABSourceCodeDirs(  );
    cache = arrayfun( @( dir )string( fullfile( matlabroot, dir.Chain{ : } ) ), dirs );
end
result = cache;
end


