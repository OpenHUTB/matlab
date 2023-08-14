classdef(Sealed)EncapsulatingSubSystemValidator<FunctionApproximation.internal.utilities.ValidatorInterface





    methods(Access=?FunctionApproximation.internal.AbstractUtils)

        function this=EncapsulatingSubSystemValidator()
        end
    end

    methods
        function success=validate(this,blockPath)
            if~FunctionApproximation.internal.Utils.isBlockPathValid(blockPath)

                success=false;
                this.Diagnostic=MException(message('SimulinkFixedPoint:functionApproximation:invalidBlockPath'));
            else
                if(FunctionApproximation.internal.BlockType.getEnum(blockPath)=="SubSystem")

                    tagOnSubSystem=get_param(blockPath,'Tag');
                    success=strcmp(tagOnSubSystem,DataTypeWorkflow.Advisor.internal.ReplacementSetUp.TagUsed);
                else

                    success=false;
                    this.Diagnostic=MException(message('SimulinkFixedPoint:functionApproximation:isNotASubSystem'));
                end
            end
        end
    end
end


