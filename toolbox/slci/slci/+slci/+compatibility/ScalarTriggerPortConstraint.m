


classdef ScalarTriggerPortConstraint<slci.compatibility.Constraint

    methods

        function out=getDescription(aObj)%#ok
            out='The signal entering a trigger port must be scalar';
        end

        function obj=ScalarTriggerPortConstraint()
            obj.setEnum('ScalarTriggerPort');
            obj.setCompileNeeded(1);
            obj.setFatal(false);
        end

        function out=check(aObj)
            out=[];
            blkSID=aObj.ParentBlock().getSID();
            parent=get_param(blkSID,'Parent');

            if strcmpi(parent,aObj.ParentModel().getName())
                dims=slResolve(get_param(blkSID,'PortDimensions'),blkSID);
                triggerWidth=1;
                for i=1:numel(dims)
                    triggerWidth=triggerWidth*dims(i);
                end

            else
                widths=get_param(parent,'CompiledPortWidths');
                triggerWidth=widths.Trigger;
            end
            if triggerWidth>1
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'ScalarTriggerPort',...
                aObj.ParentBlock().getName());
            end
        end

    end
end


