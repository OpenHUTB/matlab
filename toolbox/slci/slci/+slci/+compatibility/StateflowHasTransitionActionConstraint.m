


classdef StateflowHasTransitionActionConstraint<slci.compatibility.Constraint

    methods

        function out=getDescription(aObj)%#ok
            out='Transition actions are not supported';
        end

        function obj=StateflowHasTransitionActionConstraint
            obj.setEnum('StateflowHasTransitionAction');
            obj.setCompileNeeded(0);
            obj.setFatal(false);
        end

        function out=check(aObj)
            out=[];
            if aObj.ParentTransition().getHasTransitionAction()
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'StateflowHasTransitionAction',...
                aObj.ParentBlock().getName());
                return;
            end
        end

    end
end
