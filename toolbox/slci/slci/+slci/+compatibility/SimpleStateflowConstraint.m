



classdef SimpleStateflowConstraint<slci.compatibility.Constraint

    methods

        function out=getDescription(aObj)%#ok
            out='Atomic boxes, MATLAB functions, and action states are not supported in Stateflow charts';
        end

        function obj=SimpleStateflowConstraint
            obj.setEnum('SimpleStateflow');
            obj.setCompileNeeded(0);
            obj.setFatal(true);
        end

        function out=check(aObj)
            out=[];
            chartObj=aObj.ParentChart.getUDDObject;


            box=slci.internal.getSFActiveObjs(...
            chartObj.find('-isa','Stateflow.AtomicBox'));
            if~isempty(box)
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'SimpleStateflow',...
                aObj.ParentBlock().getName());
                return;
            end


            emFunctions=slci.internal.getSFActiveObjs(...
            chartObj.find('-isa','Stateflow.EMFunction'));
            if~isempty(emFunctions)
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'SimpleStateflow',...
                aObj.ParentBlock().getName());
                return;
            end


            actionStates=slci.internal.getSFActiveObjs(...
            chartObj.find('-isa','Stateflow.SimulinkBasedState'));
            if~isempty(actionStates)
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'SimpleStateflow',...
                aObj.ParentBlock().getName());
                return;
            end
        end

    end
end


