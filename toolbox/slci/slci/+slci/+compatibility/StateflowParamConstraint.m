


classdef StateflowParamConstraint<slci.compatibility.Constraint

    methods

        function out=getDescription(aObj)%#ok
            out='Parameter access from Stateflow charts is not supported';
        end

        function obj=StateflowParamConstraint
            obj.setEnum('StateflowParam');
            obj.setCompileNeeded(0);
            obj.setFatal(false);
        end

        function out=check(aObj)
            out=[];
            if strcmp(aObj.ParentData().getScope,'Parameter')
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'StateflowParam',...
                aObj.ParentBlock().getName());
                return;
            end
        end

    end
end

