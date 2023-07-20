




classdef StateflowExportChartFunctionsConstraint<slci.compatibility.Constraint

    methods

        function out=getDescription(aObj)%#ok
            out='Stateflow charts must deselect ''Export Chart Level Functions''';
        end

        function obj=StateflowExportChartFunctionsConstraint
            obj.setEnum('StateflowExportChartFunctions');
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
            if aObj.ParentChart().getExportChartFunctions()



                out=slci.compatibility.Incompatibility(...
                aObj,...
                'StateflowExportChartFunctions',...
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
                aObj.ParentChart().getUDDObject.ExportChartFunctions=false;
                out=true;
            catch
            end
        end

    end
end
