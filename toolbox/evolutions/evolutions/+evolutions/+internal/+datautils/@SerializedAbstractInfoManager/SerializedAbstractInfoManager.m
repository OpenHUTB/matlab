classdef(Abstract)SerializedAbstractInfoManager<...
    evolutions.internal.datautils.AbstractInfoManager






    properties(GetAccess=public,SetAccess=private)

Project

ArtifactRootFolder

RootFolder
    end

    methods(Abstract)

        loadArtifacts(obj,varargin)
    end

    methods(Access=public)
        function obj=SerializedAbstractInfoManager(fiType,project,rootFolder,artifactFolder)
            obj=obj@evolutions.internal.datautils.AbstractInfoManager(fiType);
            obj.Project=project;
            obj.RootFolder=rootFolder;
            obj.ArtifactRootFolder=fullfile(obj.RootFolder,artifactFolder);
        end

        files=getXmlFiles(obj)

        backupArtifacts(obj)

        deleteBackups(obj)

        copyFromBackup(obj)

        removeUnusedObjects(obj)

        removeUnreferencedInfos(obj)

        dm=getDependentManager(obj)

        removeUnloadedObjectsFromDisk(obj)
    end

    methods(Access=protected)
        infos=getValidInfos(obj)


        function setFileWritePath(~,ai)
            model=mf.zero.getModel(ai);
            model.ModelURI=strcat('xml@file:',ai.XmlFile);
        end
    end

end


