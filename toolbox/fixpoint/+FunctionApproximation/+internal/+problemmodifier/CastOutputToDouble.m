classdef(Sealed)CastOutputToDouble<FunctionApproximation.internal.problemmodifier.ProblemDefinitionModifier





    methods
        function problemDefinition=modify(~,problemDefinition)
            problemDefinition.InputFunctionWrapper=castToType(problemDefinition.InputFunctionWrapper,numerictype('double'));
        end
    end
end
