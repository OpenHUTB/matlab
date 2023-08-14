


classdef StateflowStateOutputMonitoringConstraint<slci.compatibility.Constraint

    methods

        function out=getDescription(aObj)%#ok
            out='Stateflow states must not select ''create output port for monitoring'' option';
        end

        function obj=StateflowStateOutputMonitoringConstraint
            obj.setEnum('StateflowStateOutputMonitoring');
            obj.setCompileNeeded(0);
            obj.setFatal(false);
        end

        function out=check(aObj)
            out=[];
            stateObj=aObj.ParentState.getUDDObject;
            if stateObj.HasOutputData
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'StateflowStateOutputMonitoring',...
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
                aObj.ParentState().getUDDObject.HasOutputData=false;
                out=true;
            catch
            end
        end

    end
end
