


classdef StateflowCustomDataConstraint<slci.compatibility.Constraint

    methods

        function out=getDescription(aObj)%#ok
            out='Custom data may not be accessed from Stateflow actions';
        end

        function obj=StateflowCustomDataConstraint
            obj.setEnum('StateflowCustomData');
            obj.setCompileNeeded(0);
            obj.setFatal(false);
        end

        function out=check(aObj)
            out=[];
            asts=aObj.getOwner().getASTs();
            for i=1:numel(asts)
                ast=asts{i};
                if ast.ContainsCustomData()
                    out=slci.compatibility.Incompatibility(...
                    aObj,...
                    'StateflowCustomData',...
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
