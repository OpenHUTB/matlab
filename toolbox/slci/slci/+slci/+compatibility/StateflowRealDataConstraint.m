


classdef StateflowRealDataConstraint<slci.compatibility.Constraint

    methods

        function out=getDescription(aObj)%#ok
            out='Complex data access from Stateflow charts is not supported';
        end

        function obj=StateflowRealDataConstraint
            obj.setEnum('StateflowRealData');
            obj.setCompileNeeded(0);
            obj.setFatal(false);
        end

        function out=check(aObj)
            out=[];
            if aObj.ParentData().getComplex()
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'StateflowRealData',...
                aObj.ParentBlock().getName());
                return;
            end
        end

    end
end

