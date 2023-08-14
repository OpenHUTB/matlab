classdef(Sealed)InfUpperBound<FunctionApproximation.internal.problemvalidator.ProblemDefinitionValidator





    properties
        ErrorID=''
    end
    methods
        function isValid=validate(~,dimensionSpecificContext)
            isValid=isinf(dimensionSpecificContext.UpperBound);
        end
    end
end
