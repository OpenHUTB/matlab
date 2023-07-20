


classdef StateflowParallelDecompositionConstraint<slci.compatibility.Constraint

    methods

        function out=getDescription(aObj)%#ok
            out='History junctions are not supported';
        end

        function obj=StateflowParallelDecompositionConstraint
            obj.setEnum('StateflowParallelDecomposition');
            obj.setCompileNeeded(0);
            obj.setFatal(false);
        end

        function out=check(aObj)
            out=[];
            if aObj.ParentState().getParallelDecomposition
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'StateflowParallelDecomposition',...
                aObj.ParentBlock().getName());
                return;
            end
        end

    end
end

