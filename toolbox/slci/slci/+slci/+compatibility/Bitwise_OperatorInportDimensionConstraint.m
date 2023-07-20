

classdef Bitwise_OperatorInportDimensionConstraint<slci.compatibility.Constraint

    methods

        function out=getDescription(aObj)%#ok
            out=['The inport of a single inport Bitwise Operator block '...
            ,'with operator AND, OR, NAND, NOR or XOR '...
            ,'in the absense of a bitmask should be scalar.'];
        end

        function obj=Bitwise_OperatorInportDimensionConstraint()
            obj.setEnum('Bitwise_OperatorInportDimension');
            obj.setCompileNeeded(0);
            obj.setFatal(false);
        end

        function out=check(aObj)
            out=[];
            portHandles=aObj.ParentBlock().getParam('PortHandles');
            operator=aObj.ParentBlock().getParam('Operator');
            if(numel(portHandles.Inport)==1&&...
                ~strcmpi(operator,'NOT'))
                ndims=get_param(portHandles.Inport(1),'CompiledPortWidth');
                if(ndims>1)
                    out=slci.compatibility.Incompatibility(...
                    aObj,...
                    'Bitwise_OperatorInportDimension',...
                    aObj.ParentBlock().getName());
                end
            end
        end

    end
end
