classdef(Sealed)LowerBoundsDimensionsValidator<FunctionApproximation.internal.problemvalidator.ProblemDefinitionValidator





    properties
        ErrorID='SimulinkFixedPoint:functionApproximation:numberOfElementsInLowerBoundsEqualToInputDimensions'
    end

    methods
        function isValid=validate(~,problemDefinition)
            isValid=numel(problemDefinition.InputLowerBounds)==problemDefinition.NumberOfInputs;
        end
    end
end
