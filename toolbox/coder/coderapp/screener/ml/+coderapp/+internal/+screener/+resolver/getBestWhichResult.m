function [ result, whichResultType ] = getBestWhichResult( symbol, aUseCachedSPKGRoot )

arguments
    symbol( 1, 1 )string
    aUseCachedSPKGRoot( 1, 1 )logical = false
end

import coderapp.internal.screener.WhichResultType;

whichResults = callWhich( symbol );
if hasUserFiles( whichResults, aUseCachedSPKGRoot )
    whichResults = removeNonUserFiles( whichResults, aUseCachedSPKGRoot );
end

if ~isPrivateFunctionPath( symbol )
    whichResults = removePrivateFunctionPaths( whichResults );
end

if ~isempty( whichResults )
    bestResult = whichResults( 1 );
    if isPFile( bestResult ) || isMexFile( bestResult )
        source = findSource( bestResult );
        if ~isempty( source )
            result = source;
            whichResultType = WhichResultType.MATLABPath;
        else
            result = bestResult;
            whichResultType = WhichResultType.MATLABPath;
        end
    elseif ~coderapp.internal.screener.resolver.isBuiltIn( bestResult )
        result = bestResult;
        whichResultType = WhichResultType.MATLABPath;
    else
        result = symbol;
        whichResultType = WhichResultType.MATLABBuiltin;
    end
else
    result = string( missing );
    whichResultType = WhichResultType.MATLABPath;
end
end

function whichResult = callWhich( symbol )
whichResult = string( coderapp.internal.screener.resolver.callWhich( symbol ) )';
end

function result = hasCaseInsensitiveExtension( filePath, extension )
[ ~, ~, ext ] = fileparts( filePath );
result = any( strcmpi( ext, extension ) );
end

function result = isMexFile( filePath )
result = hasCaseInsensitiveExtension( filePath, string( [ '.', mexext ] ) );
end

function result = isPFile( filePath )
result = hasCaseInsensitiveExtension( filePath, ".p" );
end

function result = hasUserFiles( filePathList, aUseCachedSPKGRoot )
for path = filePathList
    if coderapp.internal.screener.resolver.isUserFile( path, aUseCachedSPKGRoot )
        result = true;
        return ;
    end
end
result = false;
end

function result = removeNonUserFiles( filePathList, aUseCachedSPKGRoot )
result = string.empty;
for path = filePathList
    if coderapp.internal.screener.resolver.isUserFile( path, aUseCachedSPKGRoot )
        result( end  + 1 ) = path;%#ok<AGROW>
    end
end
end

function result = removePrivateFunctionPaths( filePathList )
result = string.empty;
for path = filePathList
    if ~isPrivateFunctionPath( path )
        result( end  + 1 ) = path;%#ok<AGROW>
    end
end
end

function result = isPrivateFunctionPath( aPath )
[ base, ~, ~ ] = fileparts( aPath );
[ base, privDir, ~ ] = fileparts( base );
[ ~, privDirParent, ~ ] = fileparts( base );


result = strcmp( privDir, "private" ) && ~startsWith( privDirParent, "@" );
end


function result = findSource( mexOrPFilePath )
if coderapp.internal.screener.resolver.isBuiltIn( mexOrPFilePath )
    result = [  ];
    return ;
end
[ path, name, ~ ] = fileparts( mexOrPFilePath );
sourcePath = fullfile( path, strcat( name, ".m" ) );
if isfile( sourcePath )
    result = sourcePath;
else
    result = [  ];
end
end


