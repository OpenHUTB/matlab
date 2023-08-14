function revealArtifactOnDisk(artUUIDOrFilePath)







    if exist(artUUIDOrFilePath,'file')

        absPth=artUUIDOrFilePath;
    elseif alm.internal.uuid.isUuid(artUUIDOrFilePath)
        artUUID=artUUIDOrFilePath;
        cprj=currentProject;
        as=alm.internal.ArtifactService.get(cprj.RootFolder);
        g=as.getGraph;
        artifact=g.getArtifactByUuid(artUUID);
        if isempty(artifact)
            error(message('dashboard:uidatamodel:ArtifactNotInGraph',artUUID));
        end

        factory=alm.StorageFactory;
        if~artifact.isFile
            artifact=g.getContainerOfPhysicalType(artifact,alm.PhysicalArtifactType.FILE);
        end
        handler=factory.createHandler(artifact.Storage);
        absPth=fullfile(handler.getAbsoluteAddress(artifact.Address));

        if~exist(absPth,'file')
            error(message('dashboard:uidatamodel:FileNotExist',absPth));
        end
    else

        error(message('dashboard:uidatamodel:FileNotExist',artUUIDOrFilePath));
    end

    folder=fileparts(absPth);

    if~exist(folder,'dir')
        error(message('dashboard:uidatamodel:FolderNotExist',folder));
    end

    if ispc
        winopen(folder);
        return
    end

    if ismac
        cmd='open';
    else


        cmd='xdg-open';
    end

    [status,msg]=system(sprintf('%s "%s"',cmd,folder));
    if status~=0
        error(message('dashboard:uidatamodel:CouldNotReveal',folder,cmd,msg));
    end
end