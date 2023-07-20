classdef(Sealed)SaturateToOutputType<FunctionApproximation.internal.problemmodifier.ProblemDefinitionModifier





    methods
        function problemDefinition=modify(~,problemDefinition)
            if problemDefinition.Options.SaturateToOutputType
                r=fixed.internal.type.finiteRepresentableRange(problemDefinition.OutputType);
                problemDefinition.InputFunctionWrapper=saturateWrapper(problemDefinition.InputFunctionWrapper,r(1),r(2));
            end
        end
    end
end
