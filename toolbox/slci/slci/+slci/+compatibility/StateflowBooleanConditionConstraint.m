


classdef StateflowBooleanConditionConstraint<slci.compatibility.Constraint

    methods

        function out=getDescription(aObj)%#ok
            out='Transition conditions must be of boolean type';
        end

        function obj=StateflowBooleanConditionConstraint
            obj.setEnum('StateflowBooleanCondition');
            obj.setCompileNeeded(1);
            obj.setFatal(false);
        end

        function out=check(aObj)
            out=[];
            cond=aObj.ParentTransition().getConditionAST();

            if~isempty(cond)...
                &&(numel(cond.getChildren)==1)...
                &&isa(cond.getChildren{1},'slci.ast.SFAstUnsupported')
                return;
            end
            if~isempty(cond)
                if~strcmp(cond.getDataType(),'boolean')
                    out=slci.compatibility.Incompatibility(...
                    aObj,...
                    'StateflowBooleanCondition',...
                    aObj.ParentBlock().getName());
                    return;
                end
            end
        end

    end
end
