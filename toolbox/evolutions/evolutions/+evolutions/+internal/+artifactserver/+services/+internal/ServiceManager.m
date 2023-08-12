classdef ServiceManager < handle




properties ( SetAccess = immutable )


StoragePath
end 

methods ( Access = private )
function obj = ServiceManager
obj.StoragePath = fullfile( 'Storage', 'FileStorage.xml' );
end 
end 

methods ( Static = true )
function serviceManager = getServiceManager
persistent localObj
if isempty( localObj ) || ~isvalid( localObj )
localObj = evolutions.internal.artifactserver.services.internal.ServiceManager;
localObj.setup;
end 
serviceManager = localObj;
end 
end 
methods ( Static = true, Access = ?evolutions.internal.artifactserver.services.Service )
function storageService = getStorageService( serverPath, type )
R36
serverPath
type( 1, : )char = 'LocalStorage'
end 
manager = evolutions.internal.artifactserver.services.internal.ServiceManager;
storageServerPath = fullfile( serverPath, manager.StoragePath );

storageService = evolutions.internal.artifactserver.services ...
.internal.( type )( storageServerPath );
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmp0h8s03.p.
% Please follow local copyright laws when handling this file.

