classdef StateflowConstantDataConstraint<slci.compatibility.Constraint



    methods

        function out=getDescription(aObj)%#ok
            out='Stateflow data must not be of Constant scope.';
        end

        function obj=StateflowConstantDataConstraint
            obj.setEnum('StateflowConstantData');
            obj.setCompileNeeded(0);
            obj.setFatal(false);
        end

        function out=check(aObj)
            out=[];
            if~strcmpi(aObj.getOwner.ParentChart.getActionLanguage,'MATLAB')...
                &&strcmpi(aObj.ParentData().getScope(),'Constant')
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'StateflowConstantData',...
                aObj.ParentBlock().getName());
                return;
            end
        end
    end

end