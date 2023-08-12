function filePath = getVarCacheFilePath( model )




buildDirs = Simulink.fileGenControl( 'getConfig' );
modeName = 'varcache';

filePath = fullfile( buildDirs.CacheFolder, 'slprj',  ...
'sim', modeName, model );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpcFbK6w.p.
% Please follow local copyright laws when handling this file.

