classdef(Sealed)InfAndNaNProtector<FunctionApproximation.internal.problemmodifier.ProblemDefinitionModifier






    methods
        function problemDefinition=modify(~,problemDefinition)
            if~fixed.internal.type.isAnyFloat(problemDefinition.OutputType)&&(problemDefinition.InputFunctionType~=FunctionApproximation.internal.FunctionType.LUTBlock)




                outputTypeRange=fixed.internal.type.finiteRepresentableRange(problemDefinition.OutputType);
                problemDefinition.InputFunctionWrapper=infProtect(problemDefinition.InputFunctionWrapper,outputTypeRange(1),outputTypeRange(2));
                problemDefinition.InputFunctionWrapper=nanProtect(problemDefinition.InputFunctionWrapper,0);
            end
        end
    end
end
