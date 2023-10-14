function whichCacheInsert( aKey, aValue, aWhichResultType )

arguments
aKey( 1, 1 )string{ mustBeNonmissing( aKey ) }
aValue( 1, 1 )string
aWhichResultType( 1, 1 )coderapp.internal.screener.WhichResultType
end 
coderapp.internal.screener.cache.unsafe.whichCacheInsert( aKey, aValue, string( aWhichResultType ) );
end 


