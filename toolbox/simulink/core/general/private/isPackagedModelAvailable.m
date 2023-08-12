function [ isPkgAvailable, packageFile ] = isPackagedModelAvailable( modelName )



narginchk( 1, 1 );

searchPath = Simulink.fileGenControl( 'get', 'CacheFolder' );

[ isPkgAvailable, packageFile ] = builtin( '_isSLCacheAvailable', modelName, searchPath );
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpFa6AsD.p.
% Please follow local copyright laws when handling this file.

