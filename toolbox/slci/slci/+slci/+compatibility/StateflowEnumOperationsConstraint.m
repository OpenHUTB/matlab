


classdef StateflowEnumOperationsConstraint<slci.compatibility.Constraint

    properties(Access=private)
        fUnsupportedOperators={'+','+=',...
        '-','-=',...
        '*','*=',...
        '/','/=',...
        '&','&=',...
        '|','|=',...
        '^','^=',...
        '%%','~',...
        '||','&&',...
        '>','<','<=','>=',...
        '~=','<>'...
        ,'>>','<<'};
    end

    methods

        function out=getDescription(aObj)
            out=['The following operations do not support enumeration type operands: '...
            ,aObj.getListOfStrings(aObj.fUnsupportedOperators,false)];
        end

        function obj=StateflowEnumOperationsConstraint
            obj.setEnum('StateflowEnumOperations');
            obj.setCompileNeeded(0);
            obj.setFatal(false);
        end

        function out=check(aObj)
            out=[];
            asts=aObj.getOwner.getASTs();
            for i=1:numel(asts)
                ast=asts{i};
                if ast.ContainsUnsupportedEnumOperations()
                    out=slci.compatibility.Incompatibility(...
                    aObj,...
                    'StateflowEnumOperations',...
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
            RecAction=DAStudio.message(['Slci:compatibility:',enum,'ConstraintRecAction'],classnames,...
            aObj.getListOfStrings(aObj.fUnsupportedOperators,false));
            StatusText=DAStudio.message(['Slci:compatibility:',enum,'Constraint',status],classnames);
        end

    end
end
