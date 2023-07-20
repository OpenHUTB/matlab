


classdef StateflowConstantConstraint<slci.compatibility.Constraint

    methods

        function out=getDescription(aObj)%#ok
            out='Constant access from Stateflow charts is not supported';
        end

        function obj=StateflowConstantConstraint
            obj.setEnum('StateflowConstant');
            obj.setCompileNeeded(0);
            obj.setFatal(false);
        end

        function out=check(aObj)
            out=[];
            if strcmp(aObj.ParentData().getScope,'Constant')
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'StateflowConstant',...
                aObj.ParentBlock().getName());
                return;
            end
        end

    end
end

