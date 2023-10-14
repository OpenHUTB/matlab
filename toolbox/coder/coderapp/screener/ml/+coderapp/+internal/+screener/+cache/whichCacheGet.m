function [ value, whichResultType ] = whichCacheGet( aKey )

arguments
    aKey( 1, 1 )string{ mustBeNonmissing( aKey ) }
end
[ value, whichResultTypeString ] = coderapp.internal.screener.cache.unsafe.whichCacheGet( aKey );
whichResultType = coderapp.internal.screener.WhichResultType( whichResultTypeString );
end



