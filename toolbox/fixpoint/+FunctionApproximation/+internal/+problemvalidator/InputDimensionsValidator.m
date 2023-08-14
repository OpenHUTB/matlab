classdef(Sealed)InputDimensionsValidator<FunctionApproximation.internal.problemvalidator.ProblemDefinitionValidator





    properties
        ErrorID='SimulinkFixedPoint:functionApproximation:numberOfInputTypesMustMatchDimensions'
    end

    methods
        function isValid=validate(~,problemDefinition)
            isValid=numel(problemDefinition.InputTypes)==problemDefinition.NumberOfInputs;
        end
    end
end
