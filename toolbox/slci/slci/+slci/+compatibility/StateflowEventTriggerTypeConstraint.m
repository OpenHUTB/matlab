


classdef StateflowEventTriggerTypeConstraint<slci.compatibility.Constraint

    methods

        function out=getDescription(aObj)%#ok
            out='Event trigger must be function call';
        end

        function obj=StateflowEventTriggerTypeConstraint
            obj.setEnum('StateflowEventTriggerType');
            obj.setCompileNeeded(0);
            obj.setFatal(false);
        end

        function out=check(aObj)
            out=[];
            if~strcmp(aObj.ParentEvent().getTrigger,'Function call')
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'StateflowEventTriggerType',...
                aObj.ParentBlock().getName());
                return;
            end
        end

    end
end

