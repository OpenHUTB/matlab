classdef(Sealed)EncapsulatedBlockValidator<FunctionApproximation.internal.utilities.ValidatorInterface





    methods(Access=?FunctionApproximation.internal.AbstractUtils)

        function this=EncapsulatedBlockValidator()
        end
    end

    methods
        function success=validate(this,blockPath)
            if~FunctionApproximation.internal.Utils.isBlockPathValid(blockPath)

                success=false;
                this.Diagnostic=MException(message('SimulinkFixedPoint:functionApproximation:invalidBlockPath'));
            else
                isUnderEncapsulatingSubsystem=DataTypeWorkflow.Advisor.Utils.isDirectlyUnderDecoupledSubsystem(blockPath);

                if isUnderEncapsulatingSubsystem


                    nameOfBlock=get_param(blockPath,'Name');
                    expectedNameOfBlock=DataTypeWorkflow.Advisor.internal.ReplacementSetUp.SourceBlockName;
                    success=strcmp(nameOfBlock,expectedNameOfBlock);
                    if~success
                        this.Diagnostic=MException(message('SimulinkFixedPoint:functionApproximation:invalidFunctionUnderEncapsulatingSubsystem'));
                    end
                else

                    success=false;
                    this.Diagnostic=MException(message('SimulinkFixedPoint:functionApproximation:blockIsNotEncapsulated'));
                end
            end
        end
    end
end