




classdef StateflowEntryExitPortConstraint<slci.compatibility.Constraint

    methods

        function out=getDescription(aObj)%#ok
            out='Exit and Entry Ports are not supported';
        end

        function obj=StateflowEntryExitPortConstraint
            obj.setEnum('StateflowEntryExitPort');
            obj.setCompileNeeded(0);
            obj.setFatal(false);
        end

        function out=check(aObj)
            out=[];
            if aObj.ParentJunction().getExitOrEntryPort
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'StateflowEntryExitPort',...
                aObj.ParentBlock().getName(),aObj.ParentJunction().getUDDObject().PortType);
                return;
            end
        end

    end
end

