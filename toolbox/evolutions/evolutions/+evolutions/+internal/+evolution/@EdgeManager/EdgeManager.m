classdef EdgeManager<...
    evolutions.internal.datautils.SerializedAbstractInfoManager






    properties

Profiles
    end

    properties(SetAccess=private,GetAccess=public)

        Constellation mf.zero.ModelConstellation
    end

    properties(Access=public,SetObservable,AbortSet)

RootEvolution
    end

    methods(Static=true)
        function edgeManager=createManager(ownerTree,constellation)

            edgeManager=...
            evolutions.internal.evolution.EdgeManager(...
            ownerTree.Project,convertStringsToChars(ownerTree.ArtifactRootFolder),"Edges",constellation,...
            '');
        end
    end

    methods(Access=public)
        function obj=EdgeManager(project,rootFolder,artifactFolder,constellation,profiles)
            obj=obj@evolutions.internal.datautils.SerializedAbstractInfoManager(...
            'evolutions.model.Edge',project,...
            rootFolder,artifactFolder);
            obj.Constellation=constellation;
            obj.Profiles=profiles;
        end

        ei=create(obj,evolution1,evolution2)

        loadArtifacts(obj,evolution)

        addEdge(obj,toEvolution,fromEvolution);

        removeEdge(obj,toEvolution,fromEvolution);

        removeEvolution(obj,ei,evManager)

        childrenDeleted=removeEvolutionBranch(obj,ei,evManager)

        insert(obj,edge)
    end
end


