classdef(Sealed)InputTypeFloatingPoint<FunctionApproximation.internal.problemvalidator.ProblemDefinitionValidator





    properties
        ErrorID=''
    end

    methods
        function isValid=validate(~,dimensionSpecificContext)
            isValid=isfloat(dimensionSpecificContext.DataType);
        end
    end
end
