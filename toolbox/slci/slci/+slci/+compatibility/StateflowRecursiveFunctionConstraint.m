


classdef StateflowRecursiveFunctionConstraint<slci.compatibility.Constraint

    methods

        function out=getDescription(aObj)%#ok
            out='Stateflow graphical functions should not be recursive.';
        end

        function obj=StateflowRecursiveFunctionConstraint
            obj.setEnum('StateflowRecursiveFunction');
            obj.setCompileNeeded(0);
            obj.setFatal(false);
        end

        function out=check(aObj)
            out=[];
            if aObj.getOwner.isRecursive()
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'StateflowRecursiveFunction',...
                aObj.ParentBlock().getName());
                return;
            end
        end

        function[SubTitle,Information,StatusText,RecAction]=getSpecificMAStrings(aObj,status,varargin)
            if status
                status='Pass';
            else
                status='Warn';
            end
            enum=aObj.getEnum();

            classnames=aObj.getOwner().getClassNames();
            Information=DAStudio.message(['Slci:compatibility:',enum,'ConstraintInfo']);
            SubTitle=DAStudio.message(['Slci:compatibility:',enum,'ConstraintSubTitle']);
            RecAction=DAStudio.message(['Slci:compatibility:',enum,'ConstraintRecAction'],classnames);
            StatusText=DAStudio.message(['Slci:compatibility:',enum,'Constraint',status],classnames);
        end

    end
end
