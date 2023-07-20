


classdef StateflowEventScopeConstraint<slci.compatibility.Constraint

    methods

        function out=getDescription(aObj)%#ok
            out='Event scope must be Output';
        end

        function obj=StateflowEventScopeConstraint
            obj.setEnum('StateflowEventScope');
            obj.setCompileNeeded(0);
            obj.setFatal(false);
        end

        function out=check(aObj)
            out=[];
            if~(strcmp(aObj.ParentEvent().getScope,'Local')...
                ||strcmp(aObj.ParentEvent().getScope,'Output'))
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'StateflowEventScope',...
                aObj.ParentBlock().getName());
                return;
            end
        end

    end
end

