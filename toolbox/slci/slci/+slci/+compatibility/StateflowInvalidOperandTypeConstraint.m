


classdef StateflowInvalidOperandTypeConstraint<slci.compatibility.Constraint

    methods

        function out=getDescription(aObj)%#ok
            out='The following math functions must have arguments of type single or double: acos, asin, atan, atan, ceil, cos, cosh, exp, fabs, floor, fmod, ldexp, log, log10, pow, sin, sinh, sqrt, tan, and tanh.  The following math functions must have arguments of non-boolean type: abs, max, min.  labs must have arguments of integer type.';
        end

        function obj=StateflowInvalidOperandTypeConstraint
            obj.setEnum('StateflowInvalidOperandType');
            obj.setCompileNeeded(0);
            obj.setFatal(false);
        end

        function out=check(aObj)
            out=[];
            asts=aObj.getOwner().getASTs();
            for i=1:numel(asts)
                ast=asts{i};
                if ast.ContainsInvalidOperandType()
                    out=slci.compatibility.Incompatibility(...
                    aObj,...
                    'StateflowInvalidOperandType',...
                    aObj.ParentBlock().getName(),...
                    aObj.getOwner().getClassNames());
                    return;
                end
            end
        end

        function[SubTitle,Information,StatusText,RecAction]=getSpecificMAStrings(aObj,status,varargin)
            if status
                status='Pass';
            else
                status='Warn';
            end
            enum=aObj.getEnum();
            classnames=aObj.getOwner.getClassNames;
            Information=DAStudio.message(['Slci:compatibility:',enum,'ConstraintInfo']);
            SubTitle=DAStudio.message(['Slci:compatibility:',enum,'ConstraintSubTitle']);
            RecAction=DAStudio.message(['Slci:compatibility:',enum,'ConstraintRecAction'],classnames);
            StatusText=DAStudio.message(['Slci:compatibility:',enum,'Constraint',status],classnames);
        end

    end
end
