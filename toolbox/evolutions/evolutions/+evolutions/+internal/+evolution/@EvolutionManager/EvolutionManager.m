classdef EvolutionManager<...
    evolutions.internal.datautils.SerializedAbstractInfoManager





    properties

Profiles
    end

    properties(SetAccess=?matlab.unittest.TestCase,GetAccess=public)

WorkingEvolution

BaseFileManager

        Constellation mf.zero.ModelConstellation
    end

    properties(Access=public,SetObservable,AbortSet)

RootEvolution
    end

    properties(Dependent,Access=public)


CurrentEvolution
    end

    methods(Static=true)
        function evolutionManager=createManager(ownerTree,constellation)

            evolutionManager=...
            evolutions.internal.evolution.EvolutionManager(...
            ownerTree.Project,convertStringsToChars(ownerTree.ArtifactRootFolder),"Evolutions",constellation,...
            '');


            evolutionManager.create;
        end
    end

    methods
        function ei=get.CurrentEvolution(obj)
            ei=obj.WorkingEvolution.Parent;
        end
    end

    methods(Access=public)

        function obj=EvolutionManager(project,rootFolder,artifactFolder,constellation,profiles)
            obj=obj@evolutions.internal.datautils.SerializedAbstractInfoManager(...
            'evolutions.model.EvolutionInfo',project,...
            rootFolder,artifactFolder);
            obj.Constellation=constellation;
            obj.BaseFileManager=evolutions.internal.file.BaseFileManager(...
            project,rootFolder,'BaseFiles',constellation);
            obj.Profiles=profiles;
        end

        ei=create(obj,eiToCopy)

        bfi=addWorkingFile(obj,bfi)

        removeWorkingFile(obj,bfi)

        bfi=getEvolutionFromId(obj,id)

        bfi=addFileToAllEvolutions(obj,files)

        removeFileFromAllEvolutions(obj,bfi)

        ei=promoteWorkingEvolution(obj,evolutionName,bfiToAfi)

        ids=getArtifactIdsForFile(obj,file)

        updateCurrentEvolution(obj,bfiToAfi)

        getEvolution(obj,ei)

        resolveOnLoad(obj)

        dm=getDependentManager(obj)

        releaseReferences(obj)

        loadArtifacts(obj);

        setDefaultProperties(obj);
    end
end


