


classdef StateflowMachineEventsConstraint<slci.compatibility.Constraint

    methods

        function out=getDescription(aObj)%#ok
            out='Stateflow events of machine scope are unsupported';
        end

        function obj=StateflowMachineEventsConstraint(varargin)
            obj.setEnum('StateflowMachineEvents');
            obj.setCompileNeeded(0);
            obj.setFatal(false);
        end

        function out=check(aObj)
            out=[];
            modelObj=aObj.ParentModel().getUDDObject();
            machineEvents=modelObj.find('-isa','Stateflow.Event','-depth',1);
            if~isempty(machineEvents)
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'StateflowMachineEvents');
                return;
            end
        end

    end
end
