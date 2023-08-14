


classdef StateflowFunctionInlineOptionConstraint<slci.compatibility.Constraint

    methods

        function out=getDescription(aObj)%#ok
            out='Stateflow functions should have the InlineOption setting set to Inline';
        end

        function obj=StateflowFunctionInlineOptionConstraint
            obj.setEnum('StateflowFunctionInlineOption');
            obj.setCompileNeeded(0);
            obj.setFatal(false);
        end

        function out=check(aObj)
            out=[];
            ast=aObj.getOwner();
            assert(isa(ast,'slci.stateflow.TruthTable')||...
            isa(ast,'slci.stateflow.SFFunction'));

            unsupportedOptions=[slci.stateflow.SFInlineOptionTypes.Auto];
            if isa(ast,'slci.stateflow.TruthTable')
                unsupportedOptions=[unsupportedOptions;...
                slci.stateflow.SFInlineOptionTypes.Function];
            end

            if any(ast.getInlineOptionEnum()==unsupportedOptions)
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'StateflowFunctionInlineOption',...
                aObj.ParentBlock().getName());
            end
        end

        function[SubTitle,Information,StatusText,RecAction]=getSpecificMAStrings(aObj,status,varargin)
            if status
                statusStr='Pass';
            else
                statusStr='Warn';
            end

            unsupported='''Auto''';
            supported='''Inline''';

            ast=aObj.getOwner();
            if isa(ast,'slci.stateflow.TruthTable')
                unsupported=[unsupported,' or ','''Function'''];
            end

            if isa(ast,'slci.stateflow.SFFunction')
                supported=[supported,' or ','''Function'''];
            end

            enum=aObj.getEnum();

            classnames=aObj.getOwner().getClassNames();
            Information=DAStudio.message(['Slci:compatibility:',enum,'ConstraintInfo']);
            SubTitle=DAStudio.message(['Slci:compatibility:',enum,'ConstraintSubTitle']);
            RecAction=DAStudio.message(['Slci:compatibility:',enum,'ConstraintRecAction'],classnames,supported);
            if status
                StatusText=DAStudio.message(['Slci:compatibility:',enum,'Constraint',statusStr],classnames,supported);
            else
                StatusText=DAStudio.message(['Slci:compatibility:',enum,'Constraint',statusStr],classnames,unsupported);
            end
        end


        function out=hasAutoFix(~)
            out=true;
        end

        function out=fix(aObj,~)
            out=aObj.setOwnerSetting('InlineOption','Inline');
        end

    end
end
