function setArtifactStorage( tree, path, storage )

arguments

    tree
    path( 1, : )char = tree.ArtifactRootFolder
    storage( 1, : )char = 'LocalStorage'
end

serverConfig = struct( 'Path', path, 'Storage', storage );

server = evolutions.internal.artifactserver.ArtifactServer( serverConfig );

serverCatalog = evolutions.internal.session.SessionManager.getServers;
serverCatalog.addServer( tree.Id, server );

