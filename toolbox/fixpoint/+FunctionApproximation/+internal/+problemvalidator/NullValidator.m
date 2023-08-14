classdef(Sealed)NullValidator<FunctionApproximation.internal.problemvalidator.ProblemDefinitionValidator




    properties
        ErrorID=''
    end

    methods
        function isValid=validate(~,~)
            isValid=true;
        end
    end
end
