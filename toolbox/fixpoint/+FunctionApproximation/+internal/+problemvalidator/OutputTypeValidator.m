classdef(Sealed)OutputTypeValidator<FunctionApproximation.internal.problemvalidator.ProblemDefinitionValidator




    properties
        ErrorID='SimulinkFixedPoint:functionApproximation:outputTypeInvalid'
    end

    methods
        function isValid=validate(~,problemDefinition)
            isValid=~any(arrayfun(@(x)isscalingunspecified(x),problemDefinition.OutputType));
        end
    end

    methods
        function diagnostic=getDiagnostic(this,problemDefinition)
            diagnostic=getDiagnostic@FunctionApproximation.internal.problemvalidator.ProblemDefinitionValidator(this,problemDefinition);
            diagnostic=diagnostic.addCause(MException(message('SimulinkFixedPoint:functionApproximation:outputTypeMustBeFullySpecified')));
        end
    end
end
