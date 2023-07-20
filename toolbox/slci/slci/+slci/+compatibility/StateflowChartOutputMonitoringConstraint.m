



classdef StateflowChartOutputMonitoringConstraint<slci.compatibility.Constraint

    methods

        function out=getDescription(aObj)%#ok
            out='Stateflow charts must not select ''create output port for monitoring child activity'' option';
        end

        function obj=StateflowChartOutputMonitoringConstraint
            obj.setEnum('StateflowChartOutputMonitoring');
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
            if chartObj.HasOutputData
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'StateflowChartOutputMonitoring',...
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
                aObj.ParentChart().getUDDObject.HasOutputData=false;
                out=true;
            catch
            end
        end

    end
end
