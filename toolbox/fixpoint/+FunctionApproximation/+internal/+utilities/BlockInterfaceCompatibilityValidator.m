classdef(Sealed)BlockInterfaceCompatibilityValidator<FunctionApproximation.internal.utilities.ValidatorInterface





    methods(Access=?FunctionApproximation.internal.AbstractUtils)

        function this=BlockInterfaceCompatibilityValidator()
        end
    end

    methods
        function success=validate(this,originalBlockPath,substituteBlockPath)

            success1=validatePath(this,originalBlockPath);
            success2=validatePath(this,substituteBlockPath);
            success=success1&success2;
            if success


                originalBlockPorts=get_param(originalBlockPath,'Ports');
                substituteBlockPorts=get_param(substituteBlockPath,'Ports');
                success=all(originalBlockPorts(1:2)==substituteBlockPorts(1:2));
            end

            if~success
                this.Diagnostic=MException(message('SimulinkFixedPoint:functionApproximation:blockInterfaceMismatch'));
                if~success1
                    this.Diagnostic=this.Diagnostic.addCause(MException(message('SimulinkFixedPoint:functionApproximation:originalPathIsInvalid')));
                end
                if~success2
                    this.Diagnostic=this.Diagnostic.addCause(MException(message('SimulinkFixedPoint:functionApproximation:substitutePathIsInvalid')));
                end
            end
        end
    end

    methods(Access=private)
        function success=validatePath(~,blockPath)
            blockType=FunctionApproximation.internal.Utils.getBlockType(blockPath);
            success=blockType~=FunctionApproximation.internal.BlockType.Invalid...
            &&blockType~=FunctionApproximation.internal.BlockType.BlockDiagram;
        end
    end
end
