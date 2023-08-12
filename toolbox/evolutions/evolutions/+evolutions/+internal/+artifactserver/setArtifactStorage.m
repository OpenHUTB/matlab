function setArtifactStorage( tree, path, storage )




R36

tree
path( 1, : )char = tree.ArtifactRootFolder
storage( 1, : )char = 'LocalStorage'
end 






serverConfig = struct( 'Path', path, 'Storage', storage );

server = evolutions.internal.artifactserver.ArtifactServer( serverConfig );

serverCatalog = evolutions.internal.session.SessionManager.getServers;
serverCatalog.addServer( tree.Id, server );

% Decoded using De-pcode utility v1.2 from file /tmp/tmpBYqpR0.p.
% Please follow local copyright laws when handling this file.

