function artifactId=deleteArtifacts(currentTreeInfo,artifactId)




    currentPath=pwd;
    cleanup=onCleanup(@()cd(currentPath));

    cd(currentTreeInfo.Project.RootFolder);


    serverCatalog=evolutions.internal.session.SessionManager.getServers;
    server=serverCatalog.getServer(currentTreeInfo.Id);

    for idx=1:numel(artifactId)
        server.deleteArtifacts(artifactId{idx});
    end
end