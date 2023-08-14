



classdef MatlabFunctionInputTriggerConstraint<slci.compatibility.Constraint

    methods


        function out=getDescription(aObj)%#ok
            out='Input trigger signals are not supported in Matlab Function Blocks';
        end


        function obj=MatlabFunctionInputTriggerConstraint
            obj.setEnum('MatlabFunctionInputTrigger');
            obj.setFatal(false);
        end


        function out=check(aObj)
            out=[];
            chart=aObj.ParentChart;
            assert(~isempty(chart));
            chartObj=chart.getUDDObject;
            triggerSignals=chartObj.find('-isa','Stateflow.Trigger');
            if~isempty(triggerSignals)
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'MatlabFunctionInputTrigger',...
                aObj.ParentBlock().getName());
            end
        end
    end

end
