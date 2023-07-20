


classdef StateflowLocalDataConstraint<slci.compatibility.Constraint

    methods

        function out=getDescription(aObj)%#ok
            out='Local data access from Stateflow charts is not supported';
        end

        function obj=StateflowLocalDataConstraint
            obj.setEnum('StateflowLocalData');
            obj.setCompileNeeded(0);
            obj.setFatal(false);
        end

        function out=check(aObj)
            out=[];
            if strcmp(aObj.ParentData().getScope,'Local')
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'StateflowLocalData',...
                aObj.ParentBlock().getName());
                return;
            end
        end

    end
end

