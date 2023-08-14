




classdef StateflowVarSizesConstraint<slci.compatibility.Constraint

    methods

        function out=getDescription(aObj)%#ok
            out='Stateflow charts or atomic subcharts must deselect ''Support variable-size arrays''';
        end

        function obj=StateflowVarSizesConstraint
            obj.setEnum('StateflowVarSizes');
            obj.setCompileNeeded(0);
            obj.setFatal(true);
        end

        function out=check(aObj)
            if aObj.getOwner().isAtomicSubchart()
                stateflowObjType=DAStudio.message('Slci:compatibility:ClassTypeAtomicSubchart');
            else
                stateflowObjType=DAStudio.message('Slci:compatibility:ClassTypeChart');
            end

            out=[];
            if aObj.ParentChart().getSupportVariableSizing()
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'StateflowVarSizes',...
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
                aObj.ParentChart().getUDDObject.SupportVariableSizing=false;
                out=true;
            catch
            end
        end

    end
end
