







classdef StateflowUniqueFunctionNameConstraint<slci.compatibility.Constraint

    methods


        function out=getDescription(aObj)%#ok
            out='Stateflow charts or atomic subchart must use unique name for Simulink function, graphical function, and truth table.''';
        end


        function obj=StateflowUniqueFunctionNameConstraint
            obj.setEnum('StateflowUniqueFunctionName');
            obj.setCompileNeeded(0);
            obj.setFatal(false);
        end


        function out=check(aObj)

            if aObj.getOwner().isAtomicSubchart()
                stateflowObjType=DAStudio.message('Slci:compatibility:ClassTypeAtomicSubchart');
            else
                stateflowObjType=DAStudio.message('Slci:compatibility:ClassTypeChart');
            end

            out=[];
            chart=aObj.ParentChart;
            assert(isa(chart,'slci.stateflow.Chart'));
            if strcmpi(chart.getActionLanguage,'MATLAB')...
                &&chart.hasSameFuncName
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'StateflowUniqueFunctionName',...
                stateflowObjType,...
                aObj.ParentBlock().getName());
            end
        end

    end
end
