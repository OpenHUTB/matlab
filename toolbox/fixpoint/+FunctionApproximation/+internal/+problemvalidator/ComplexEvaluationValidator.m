classdef(Sealed)ComplexEvaluationValidator<FunctionApproximation.internal.problemvalidator.ProblemDefinitionValidator








    properties
        ErrorID='SimulinkFixedPoint:functionApproximation:complexEvaluationNotSupported'
    end

    methods
        function isValid=validate(~,problemDefinition)
            isValid=isreal(problemDefinition.SampledTableData);
        end
    end
end