classdef(Sealed)HandleVectorizationModifier<FunctionApproximation.internal.problemmodifier.ProblemDefinitionModifier





    methods
        function problemDefinition=modify(this,problemDefinition)
            canHandleVectorInputs=FunctionApproximation.internal.Utils.isFunctionVectorized(...
            problemDefinition.InputFunctionWrapper,...
            problemDefinition.InputLowerBounds,...
            problemDefinition.InputUpperBounds,...
            problemDefinition.InputTypes);
            problemDefinition.InputFunctionWrapper.setVectorized(canHandleVectorInputs);
            if~canHandleVectorInputs
                this.MessageRepository.addMessage(message('SimulinkFixedPoint:functionApproximation:handleVectorization').getString());
            end
        end
    end
end
