function [ whichResult, whichResultType ] = getBestEMLWhichResult( symbol, aUseCachedSPKGRoot )

arguments
    symbol( 1, 1 )string
    aUseCachedSPKGRoot( 1, 1 )logical = false
end
[ whichResultArr, whichResultTypeArr ] = coderapp.internal.screener.resolver.emlWhich( symbol, aUseCachedSPKGRoot );
if isempty( whichResultArr )
    whichResult = string( missing );
    whichResultType = coderapp.internal.screener.WhichResultType.MATLABPath;
else
    whichResult = whichResultArr( 1 );
    whichResultType = whichResultTypeArr( 1 );
end
end


