classdef(Sealed)SampleDataCreator<FunctionApproximation.internal.problemmodifier.ProblemDefinitionModifier






    methods
        function problemDefinition=modify(~,problemDefinition)
            rangeObject=FunctionApproximation.internal.Range(...
            problemDefinition.InputLowerBounds,problemDefinition.InputUpperBounds);

            [useBruteForce,nPoints]=FunctionApproximation.internal.canBruteForceGridingBeUsed(rangeObject,problemDefinition.InputTypes);
            problemDefinition.IsGridExhaustive=useBruteForce;
            if~useBruteForce


                nPoints(nPoints>2^19)=2^19;
                nPoints=floor(nPoints*(2^18/prod(nPoints))^(1/numel(nPoints)));
            end
            nPoints=max(nPoints,2);
            [problemDefinition.SampledTableData,problemDefinition.SamplingGrid]=...
            FunctionApproximation.internal.getValues(problemDefinition.InputFunctionWrapper,...
            problemDefinition.InputTypes,rangeObject,nPoints);
        end
    end
end