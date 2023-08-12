
function result = getBuildDir( modelName )
modelIsLoaded = bdIsLoaded( modelName );
if ~modelIsLoaded
load_system( modelName );
oc = onCleanup( @(  )close_system( modelName ) );
end 
result = RTW.getBuildDir( modelName );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpMmmTwK.p.
% Please follow local copyright laws when handling this file.

