


classdef StateflowHistoryJunctionConstraint<slci.compatibility.Constraint

    methods

        function out=getDescription(aObj)%#ok
            out='History junctions are not supported';
        end

        function obj=StateflowHistoryJunctionConstraint
            obj.setEnum('StateflowHistoryJunction');
            obj.setCompileNeeded(0);
            obj.setFatal(false);
        end

        function out=check(aObj)
            out=[];
            if aObj.ParentJunction().getHistoryJunction
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'StateflowHistoryJunction',...
                aObj.ParentBlock().getName());
                return;
            end
        end

    end
end

