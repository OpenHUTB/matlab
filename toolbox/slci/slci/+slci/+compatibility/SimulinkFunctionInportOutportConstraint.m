



classdef SimulinkFunctionInportOutportConstraint<slci.compatibility.Constraint
    methods


        function out=getDescription(aObj)%#ok
            out=['SLCI does not support Input and Output block '
            'Simulink Function subsystem'];
        end


        function obj=SimulinkFunctionInportOutportConstraint()
            obj.setEnum('SimulinkFunctionInportOutport')
            obj.setCompileNeeded(0);
            obj.setFatal(false);
        end

        function out=check(aObj)
            out=[];
            sub=aObj.getOwner;
            assert(isa(sub,'slci.simulink.SubSystemBlock'));
            blkObj=get_param(sub.getHandle,'Object');
            assert(strcmpi(slci.internal.getSubsystemType(blkObj),...
            'simulinkfunction'));
            inports=blkObj.PortHandles.Inport;
            if isempty(inports)&&isempty(blkObj.PortHandles.Outport)
                return
            end
            out=slci.compatibility.Incompatibility(aObj,...
            aObj.getEnum(),...
            aObj.ParentModel().getName());

        end
    end
end