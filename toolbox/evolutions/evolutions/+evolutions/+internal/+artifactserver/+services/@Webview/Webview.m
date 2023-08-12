classdef Webview < evolutions.internal.artifactserver.services.Service




properties 
StorageType
end 

methods 
function obj = Webview( ServiceDBPath, storageType )
R36
ServiceDBPath
storageType( 1, : )char = 'LocalStorage'
end 
obj@evolutions.internal.artifactserver.services.Service( ServiceDBPath );
obj.StorageType = storageType;
end 

storage = getStorageService( obj )

tf = create( obj, data )

file = read( obj, data )

tf = deleteArtifact( obj, data )
end 

methods ( Access = protected )
function tempDir = getTempDir( obj )
tempDir = fullfile( obj.getServerDirectory, 'slprj', 'webviews' );
end 
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmp4cttF9.p.
% Please follow local copyright laws when handling this file.

