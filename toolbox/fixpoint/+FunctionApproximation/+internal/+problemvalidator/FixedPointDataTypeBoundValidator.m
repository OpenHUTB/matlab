classdef(Sealed)FixedPointDataTypeBoundValidator<FunctionApproximation.internal.problemvalidator.CompositeProblemDefinitionValidator






    properties
        ErrorID='SimulinkFixedPoint:functionApproximation:needBoundsForScaling'
        ValidationExpression=@(x)~(x(1)&(x(2)|x(3)))
    end

    methods
        function this=FixedPointDataTypeBoundValidator()
            this.ChildValidators=[...
            FunctionApproximation.internal.problemvalidator.InputTypeUnspecifiedScaling(),...
            FunctionApproximation.internal.problemvalidator.InfLowerBound(),...
            FunctionApproximation.internal.problemvalidator.InfUpperBound(),...
            ];
        end
    end

    methods
        function diagnostic=getDiagnostic(this,dimensionSpecificContext)
            diagnostic=MException(message(this.ErrorID,dimensionSpecificContext.Dimension));
        end
    end
end
