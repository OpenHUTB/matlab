classdef(Sealed)FloatingPointDataTypeLowerBoundValidator<FunctionApproximation.internal.problemvalidator.CompositeProblemDefinitionValidator






    properties
        ErrorID='SimulinkFixedPoint:functionApproximation:lowerBoundMustBeSpecifiedIfTypeIsDouble'
        ValidationExpression=@(x)~(x(1)&x(2))
    end

    methods
        function this=FloatingPointDataTypeLowerBoundValidator()
            this.ChildValidators=[...
            FunctionApproximation.internal.problemvalidator.InputTypeFloatingPoint(),...
            FunctionApproximation.internal.problemvalidator.InfLowerBound(),...
            ];
        end
    end

    methods
        function diagnostic=getDiagnostic(this,dimensionSpecificContext)
            diagnostic=MException(message(this.ErrorID,dimensionSpecificContext.Dimension));
        end
    end
end
