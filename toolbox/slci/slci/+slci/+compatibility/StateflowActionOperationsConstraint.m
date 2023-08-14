


classdef StateflowActionOperationsConstraint<slci.compatibility.Constraint


    methods

        function out=getDescription(aObj)%#ok
            out='We support the following operations: :=, =, +, +=, -, -=, *, *=, /, /=, &, &&, &=, |, ||, |=, <<, >>, cast(), ^, ^=, %%, <, <=, ==, ~=, !=, <>, >, >=, and ~';
        end

        function obj=StateflowActionOperationsConstraint
            obj.setEnum('StateflowActionOperations');
            obj.setCompileNeeded(0);
            obj.setFatal(false);
        end

        function out=check(aObj)
            out=[];
            chart=aObj.getOwner.ParentChart;
            assert(isa(chart,'slci.stateflow.Chart'));
            if strcmpi(chart.getActionLanguage,'MATLAB')
                return;
            end
            asts=aObj.getOwner.getASTs();
            for i=1:numel(asts)
                ast=asts{i};
                if ast.ContainsUnsupportedAST()||...
                    ast.ContainsUnsupportedFunction()||...
                    ast.ContainsEnumCast()
                    out=slci.compatibility.Incompatibility(...
                    aObj,...
                    'StateflowActionOperations',...
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
