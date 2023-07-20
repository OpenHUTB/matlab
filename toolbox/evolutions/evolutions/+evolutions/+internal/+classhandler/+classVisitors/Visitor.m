classdef Visitor<handle





    methods
        function visit(obj,classObj)
            if isa(classObj,'evolutions.model.BaseFileInfo')
                obj.visitObjects(classObj,'visitBaseFileInfo');
            elseif isa(classObj,'evolutions.model.EvolutionInfo')
                obj.visitObjects(classObj,'visitEvolutionInfo');
            elseif isa(classObj,'evolutions.model.Edge')
                obj.visitObjects(classObj,'visitEdge');
            else
                assert(isa(classObj,'evolutions.model.EvolutionTreeInfo'),'Visitor for type not found');
                obj.visitObjects(classObj,'visitEvolutionTreeInfo');
            end
        end
    end

    methods(Access=private)
        function visitObjects(obj,classObj,visitFunction)
            for objIdx=1:numel(classObj)
                obj.(visitFunction)(classObj(objIdx));
            end
        end
    end
end
