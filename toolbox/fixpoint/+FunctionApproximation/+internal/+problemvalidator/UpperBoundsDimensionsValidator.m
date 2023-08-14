classdef(Sealed)UpperBoundsDimensionsValidator<FunctionApproximation.internal.problemvalidator.ProblemDefinitionValidator





    properties
        ErrorID='SimulinkFixedPoint:functionApproximation:numberOfElementsInUpperBoundsEqualToInputDimensions'
    end

    methods
        function isValid=validate(~,problemDefinition)
            isValid=numel(problemDefinition.InputUpperBounds)==problemDefinition.NumberOfInputs;
        end
    end
end
