


classdef StateflowScalarDataConstraint<slci.compatibility.Constraint

    methods

        function out=getDescription(aObj)%#ok
            out='Non-scalar data access from Stateflow charts is not supported';
        end

        function obj=StateflowScalarDataConstraint
            obj.setEnum('StateflowScalarData');
            obj.setCompileNeeded(0);
            obj.setFatal(false);
        end

        function out=check(aObj)
            out=[];
            if aObj.ParentData().getWidth>1
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'StateflowScalarData',...
                aObj.ParentBlock().getName());
                return;
            end
        end

    end
end

