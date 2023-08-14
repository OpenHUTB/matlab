classdef StateflowStateActivityLoggingConstraint<slci.compatibility.Constraint




    methods
        function obj=StateflowStateActivityLoggingConstraint
            obj.setEnum('StateflowStateActivityLoggingConstraint');
            obj.setCompileNeeded(0);
            obj.setFatal(false);
        end

        function out=check(aObj)
            out=[];
            stateUddObj=aObj.getOwner().getUDDObject();
            if(stateUddObj.LoggingInfo.DataLogging||stateUddObj.TestPoint)
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'StateflowStateActivityLoggingConstraint',...
                aObj.ParentBlock().getName());
                return;
            end
        end
    end
end
