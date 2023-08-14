classdef(Sealed)InfLowerBound<FunctionApproximation.internal.problemvalidator.ProblemDefinitionValidator





    properties
        ErrorID=''
    end
    methods
        function isValid=validate(~,dimensionSpecificContext)
            isValid=isinf(dimensionSpecificContext.LowerBound);
        end
    end
end
