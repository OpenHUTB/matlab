function getArtifacts(currentTreeInfo,evolution)








    currentPath=pwd;
    cleanup=onCleanup(@()cd(currentPath));

    cd(currentTreeInfo.Project.RootFolder);

    baseToArtifacts=evolution.BaseIdtoArtifactId;
    bfis=evolution.Infos;

    for bfiIdx=1:bfis.Size
        curBfi=bfis(bfiIdx);
        afiId=baseToArtifacts.at(curBfi.Id);
        try
            serverCatalog=evolutions.internal.session.SessionManager.getServers;
            server=serverCatalog.getServer(currentTreeInfo.Id);

            if(fileIsOutdated(currentTreeInfo,curBfi,evolution))
                server.readArtifacts(curBfi.File,afiId);
            end
        catch ME




            newME=MException('Evolutions:FileReadFail',...
            getString(message('evolutions:manage:FileReadFail')));
            newME=addCause(newME,ME);
            evolutions.internal.session.EventHandler.publish('NonCriticalError',...
            evolutions.internal.ui.GenericEventData(newME));

        end
    end

end

function tf=fileIsOutdated(currentTreeInfo,curBfi,evolution)

    file=curBfi.File;
    if isfile(file)

        fileChecksum=evolutions.internal.utils.getFileChecksumFromPath(file);


        data=evolutions.internal.artifactserver.getFileMetaData(currentTreeInfo,curBfi,evolution);

        tf=~isequal(fileChecksum,data.Data.CheckSum);
    else

        tf=true;
    end
end


