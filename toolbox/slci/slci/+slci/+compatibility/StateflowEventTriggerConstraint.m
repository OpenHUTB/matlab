


classdef StateflowEventTriggerConstraint<slci.compatibility.Constraint

    methods

        function out=getDescription(aObj)%#ok
            out='We only support the following operations in Stateflow actions: =, +, -, *, /, &&, ||, <, <=, ==, ~=, >, >=, and ~';
        end

        function obj=StateflowEventTriggerConstraint
            obj.setEnum('StateflowEventTrigger');
            obj.setCompileNeeded(0);
            obj.setFatal(false);
        end

        function out=check(aObj)
            out=[];
            cond=aObj.ParentTransition().getConditionAST();
            if~isempty(cond)
                if cond.ContainsEventTrigger()
                    out=slci.compatibility.Incompatibility(...
                    aObj,...
                    'StateflowEventTrigger',...
                    aObj.ParentBlock().getName());
                    return;
                end
            end
        end

    end
end
