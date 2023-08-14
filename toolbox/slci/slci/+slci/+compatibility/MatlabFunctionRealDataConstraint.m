


classdef MatlabFunctionRealDataConstraint<slci.compatibility.Constraint

    methods

        function out=getDescription(aObj)%#ok
            out='MATLAB Function does not support complex data';
        end

        function obj=MatlabFunctionRealDataConstraint
            obj.setEnum('MatlabFunctionRealData');
            obj.setCompileNeeded(0);
            obj.setFatal(false);
        end

        function out=check(aObj)
            out=[];
            if aObj.ParentData().getComplex()
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'MatlabFunctionRealData',...
                aObj.ParentBlock().getName());
                return;
            end
        end

    end
end
