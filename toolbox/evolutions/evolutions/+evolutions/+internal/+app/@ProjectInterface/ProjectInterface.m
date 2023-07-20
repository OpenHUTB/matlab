classdef ProjectInterface<handle





    properties(SetAccess=protected)
ProjectManager
EvolutionTreeManager
    end

    methods
        function obj=ProjectInterface
            obj.ProjectManager=evolutions.internal.project.ProjectManager.get;
            obj.ProjectManager.reset;
        end
    end

    methods

        output=getReferenceProjects(h);


        [output1,output2]=getEvolutionTreeData(h,evolutionTree);
        output=getEvolutionTreeWorkingNode(h,evolutionTree)
        output=getEvolutionTrees(h,currentProject);
    end
end
