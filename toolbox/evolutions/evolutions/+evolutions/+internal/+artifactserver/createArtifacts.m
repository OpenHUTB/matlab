function artifactId=createArtifacts(currentTreeInfo,baseFileInfos)




    currentPath=pwd;
    cleanup=onCleanup(@()cd(currentPath));

    cd(currentTreeInfo.Project.RootFolder);


    artifactId=matlab.lang.internal.uuid();

    try

        serverCatalog=evolutions.internal.session.SessionManager.getServers;
        server=serverCatalog.getServer(currentTreeInfo.Id);
        file=evolutions.internal.utils.getRelativePathFromProject(baseFileInfos,baseFileInfos.File);
        server.generateArtifacts(file,artifactId);
    catch ME


        newME=MException('Evolutions:FileWriteFail',...
        getString(message('evolutions:manage:FileWriteFail')));
        newME=addCause(newME,ME);
        evolutions.internal.session.EventHandler.publish('NonCriticalError',...
        evolutions.internal.ui.GenericEventData(newME));
    end
end


