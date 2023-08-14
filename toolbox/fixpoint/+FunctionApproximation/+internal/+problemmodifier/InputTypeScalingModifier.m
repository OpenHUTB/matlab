classdef(Sealed)InputTypeScalingModifier<FunctionApproximation.internal.problemmodifier.ProblemDefinitionModifier





    methods
        function problemDefinition=modify(~,problemDefinition)
            for ii=problemDefinition.NumberOfInputs:-1:1
                if isfixed(problemDefinition.InputTypes(ii))&&isscalingunspecified(problemDefinition.InputTypes(ii))
                    values=[problemDefinition.InputLowerBounds(ii),problemDefinition.InputUpperBounds(ii)];
                    problemDefinition.InputTypes(ii)=...
                    FunctionApproximation.internal.scaleDataType(problemDefinition.InputTypes(ii),values);
                end
            end
        end
    end
end
