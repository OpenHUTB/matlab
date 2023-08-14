




classdef StateflowSaturateOnIntOverflowConstraint<slci.compatibility.Constraint

    methods

        function out=getDescription(aObj)%#ok
            out='Stateflow charts or atomic subcharts must deselect ''Saturate on integer overflow''';
        end

        function obj=StateflowSaturateOnIntOverflowConstraint
            obj.setEnum('StateflowSaturateOnIntOverflow');
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
            if aObj.ParentChart().getSaturateOnIntegerOverflow()
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'StateflowSaturateOnIntOverflow',...
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
                aObj.ParentChart().getUDDObject.SaturateOnIntegerOverflow=false;
                out=true;
            catch
            end
        end


    end
end
