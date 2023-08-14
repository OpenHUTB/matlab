classdef(Sealed)InputTypeUnspecifiedScaling<FunctionApproximation.internal.problemvalidator.ProblemDefinitionValidator





    properties
        ErrorID=''
    end

    methods
        function isValid=validate(~,dimensionSpecificContext)
            isValid=isscalingunspecified(dimensionSpecificContext.DataType);
        end
    end
end
