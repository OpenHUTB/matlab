classdef(Sealed)ElementWiseOperationFunction<FunctionApproximation.internal.problemvalidator.ProblemDefinitionValidator





    properties
        ErrorID='SimulinkFixedPoint:functionApproximation:functionNotVectorized'
    end

    methods
        function isValid=validate(~,problemDefinition)
            isValid=FunctionApproximation.internal.Utils.isFunctionElementWiseOperation(...
            problemDefinition.InputFunctionWrapper,...
            problemDefinition.InputLowerBounds,...
            problemDefinition.InputUpperBounds,...
            problemDefinition.InputTypes);
        end
    end
end
