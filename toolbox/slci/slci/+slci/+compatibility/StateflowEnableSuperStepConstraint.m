



classdef StateflowEnableSuperStepConstraint<slci.compatibility.Constraint

    methods

        function out=getDescription(aObj)%#ok
            out='Stateflow charts or atomic subcharts must not select ''Enable super step semantics'' option';
        end

        function obj=StateflowEnableSuperStepConstraint
            obj.setEnum('StateflowEnableSuperStep');
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
            chartObj=aObj.ParentChart.getUDDObject;
            if chartObj.EnableNonTerminalStates
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'StateflowEnableSuperStep',...
                stateflowObjType,...
                aObj.ParentBlock().getName());
                return;
            end
        end

        function out=hasAutoFix(~)
            out=true;
        end

        function out=fix(aObj,~)
            out=false;
            try
                aObj.ParentChart().getUDDObject.EnableNonTerminalStates=false;
                out=true;
            catch
            end
        end

    end
end
