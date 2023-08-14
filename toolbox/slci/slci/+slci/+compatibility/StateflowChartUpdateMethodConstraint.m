



classdef StateflowChartUpdateMethodConstraint<slci.compatibility.Constraint

    methods

        function out=getDescription(aObj)%#ok
            out='Stateflow charts or atomic subcharts must set its update method to ''Inherited''';
        end

        function obj=StateflowChartUpdateMethodConstraint
            obj.setEnum('StateflowChartUpdateMethod');
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
            if~strcmp(aObj.ParentChart().getChartUpdate(),'INHERITED')
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'StateflowChartUpdateMethod',...
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
                aObj.ParentChart().getUDDObject.ChartUpdate='INHERITED';
                out=true;
            catch
            end
        end

    end
end
