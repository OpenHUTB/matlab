function [ value, whichResultType ] = whichCacheGet( aKey )




R36
aKey( 1, 1 )string{ mustBeNonmissing( aKey ) }
end 
[ value, whichResultTypeString ] = coderapp.internal.screener.cache.unsafe.whichCacheGet( aKey );
whichResultType = coderapp.internal.screener.WhichResultType( whichResultTypeString );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpgCl0qd.p.
% Please follow local copyright laws when handling this file.

