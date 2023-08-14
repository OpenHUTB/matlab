classdef EvolutionInterface<evolutions.internal.ui.tools.ServerInterface




    properties(Hidden,SetAccess=immutable)
AppModel
TreeListManager
ProjectListManager
    end

    methods
        function obj=EvolutionInterface(appModel)
            if isequal(nargin,1)
                obj.AppModel=appModel;
                obj.ProjectListManager=getSubModel(obj.AppModel,'ProjectReferenceListManager');
                obj.TreeListManager=getSubModel(obj.AppModel,'EvolutionTreeListManager');
            end
        end
    end

    methods

        output=createEvolutionTree(obj,projectInfo);
        deleteEvolutionTree(obj,projectInfo,evolutionTreeInfo);
        changeEvolutionTreeName(obj,evolutionTreeInfo,name);


        syncFilesWithProject(obj);


        changeEvolutionInfoName(h,evolution,name);
        [status,outputMessage]=getEvolution(h,evolution);
        [status,outputMessage]=createEvolution(h);
        [status,outputMessage]=updateEvolution(h,evolution);
        status=deleteEvolutions(h,evolution);
        status=deleteSingleEvolution(h,evolution);


        changeInfoPropertyData(h,info,data)


        output=compareFiles(h,evolution1Id,evolution2Id,fileName);


        differences=calculateEvolutionDifferences(h,evolution1,evolutions2);
        edge=getEdgeInfo(h,toEvolution,fromEvolution);
    end
end


