function meta=getFileMetaData(treeInfo,bfi,evolution)





    serverCatalog=evolutions.internal.session.SessionManager.getServers;
    server=serverCatalog.getServer(treeInfo.Id);


    artifactKey=evolution.BaseIdtoArtifactId.at(bfi.Id);
    [~,meta]=server.getVersionMeta(bfi.File,artifactKey);
end
