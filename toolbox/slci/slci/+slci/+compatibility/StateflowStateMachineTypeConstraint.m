

classdef StateflowStateMachineTypeConstraint<slci.compatibility.Constraint

    methods

        function out=getDescription(aObj)%#ok
            out='Stateflow charts must not select ''Moore'' for ''State Machine Type''. ';
        end

        function obj=StateflowStateMachineTypeConstraint
            obj.setEnum('StateflowStateMachineType');
            obj.setCompileNeeded(0);
            obj.setFatal(false);
        end

        function out=check(aObj)
            out=[];
            chartObj=aObj.ParentChart.getUDDObject;
            if strcmpi(chartObj.StateMachineType,'Moore')
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'StateflowStateMachineType',...
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
                aObj.ParentChart().getUDDObject.StateMachineType='Classic';
                out=true;
            catch
            end
        end

    end
end
