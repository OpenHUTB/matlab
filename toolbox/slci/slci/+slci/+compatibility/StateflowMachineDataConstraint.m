


classdef StateflowMachineDataConstraint<slci.compatibility.Constraint

    methods

        function out=getDescription(aObj)%#ok
            out='Stateflow data of machine scope is unsupported';
        end

        function obj=StateflowMachineDataConstraint(varargin)
            obj.setEnum('StateflowMachineData');
            obj.setCompileNeeded(0);
            obj.setFatal(false);
        end

        function out=check(aObj)
            out=[];
            modelObj=aObj.ParentModel().getUDDObject();
            machineData=modelObj.find('-isa','Stateflow.Data','-depth',1);
            if~isempty(machineData)
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'StateflowMachineData');
                return;
            end
        end

    end
end
