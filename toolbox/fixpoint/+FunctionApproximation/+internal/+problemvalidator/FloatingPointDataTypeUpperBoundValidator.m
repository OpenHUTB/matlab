classdef(Sealed)FloatingPointDataTypeUpperBoundValidator<FunctionApproximation.internal.problemvalidator.CompositeProblemDefinitionValidator






    properties
        ErrorID='SimulinkFixedPoint:functionApproximation:upperBoundMustBeSpecifiedIfTypeIsDouble'
        ValidationExpression=@(x)~(x(1)&x(2))
    end

    methods
        function this=FloatingPointDataTypeUpperBoundValidator()
            this.ChildValidators=[...
            FunctionApproximation.internal.problemvalidator.InputTypeFloatingPoint(),...
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
