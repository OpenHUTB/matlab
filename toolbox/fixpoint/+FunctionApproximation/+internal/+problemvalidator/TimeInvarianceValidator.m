classdef(Sealed)TimeInvarianceValidator<FunctionApproximation.internal.problemvalidator.ProblemDefinitionValidator





    properties
        ErrorID='SimulinkFixedPoint:functionApproximation:subsystemNotTimeInvariant'
    end

    methods
        function isValid=validate(~,problemDefinition)
            isValid=true;
            if(problemDefinition.InputFunctionType=="SubSystem")&&~isempty(problemDefinition.InputFunctionWrapper.Data)
                isValid=~FunctionApproximation.internal.Utils.isFunctionTimeVariant(...
                problemDefinition.InputFunctionWrapper,...
                problemDefinition.InputLowerBounds,...
                problemDefinition.InputUpperBounds);
            end
        end
    end
end
