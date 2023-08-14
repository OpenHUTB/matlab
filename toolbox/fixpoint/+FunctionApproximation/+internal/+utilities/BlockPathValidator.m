classdef(Sealed)BlockPathValidator<FunctionApproximation.internal.utilities.ValidatorInterface





    methods(Access=?FunctionApproximation.internal.AbstractUtils)

        function this=BlockPathValidator()
        end
    end

    methods
        function success=validate(this,blockPath)

            blockType=FunctionApproximation.internal.Utils.getBlockType(blockPath);
            success=blockType~=FunctionApproximation.internal.BlockType.Invalid;
            if success&&blockType~=FunctionApproximation.internal.BlockType.BlockDiagram

                success=strcmp(get_param(blockPath,'Commented'),'off');
            end
            if~success
                this.Diagnostic=MException(message('SimulinkFixedPoint:functionApproximation:invalidBlockPath'));
            end
        end
    end
end
