classdef(Sealed)InterpolationModeNoneValidator<FunctionApproximation.internal.problemvalidator.ProblemDefinitionValidator





    properties
        ErrorID='SimulinkFixedPoint:functionApproximation:interpolationNoneInterfaceTypeCheck'
    end

    methods
        function isValid=validate(~,problemDefinition)
            isValid=true;
            if problemDefinition.Options.Interpolation=="None"





                isValid=~any(arrayfun(@(x)isfloat(x),problemDefinition.InputTypes))...
                &&~any(arrayfun(@(x)fixed.DataTypeSelector.isSlopeBiasScaling(x),problemDefinition.InputTypes))...
                &&~any(arrayfun(@(x)fixed.DataTypeSelector.isSlopeBiasScaling(x),problemDefinition.OutputType));

                if isValid
                    rangeObject=FunctionApproximation.internal.Range(...
                    problemDefinition.InputLowerBounds,problemDefinition.InputUpperBounds);

                    [~,nPoints]=FunctionApproximation.internal.canBruteForceGridingBeUsed(rangeObject,problemDefinition.InputTypes);

                    isValid=isValid&&(prod(nPoints)<=2^26);
                end
            end
        end
    end
end