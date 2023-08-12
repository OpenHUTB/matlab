function [ whichResult, whichResultType ] = getCachedBestWhichResult( symbol, useEMLWhich )


























R36
symbol( 1, 1 )string
useEMLWhich( 1, 1 )logical
end 

[ whichResult, whichResultType ] = coderapp.internal.screener.cache.whichCacheGet( symbol );
if isempty( whichResult )
aUseCachedSPKGRoot = true;
[ whichResult, whichResultType ] = getBestWhichResult( symbol, aUseCachedSPKGRoot, useEMLWhich );
coderapp.internal.screener.cache.whichCacheInsert( symbol, whichResult, whichResultType );
end 
end 

function [ whichResult, whichResultType ] = getBestWhichResult( symbol, aUseCachedSPKGRoot, useEMLWhich )
import coderapp.internal.screener.*;
if useEMLWhich
[ whichResult, whichResultType ] = resolver.getBestEMLWhichResult( symbol, aUseCachedSPKGRoot );
else 
[ whichResult, whichResultType ] = resolver.getBestWhichResult( symbol, aUseCachedSPKGRoot );
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpNRlm2B.p.
% Please follow local copyright laws when handling this file.

