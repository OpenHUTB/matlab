classdef(Sealed)SpecialFunctionHandleValidator<FunctionApproximation.internal.utilities.ValidatorInterface






    methods(Access=?FunctionApproximation.internal.AbstractUtils)

        function this=SpecialFunctionHandleValidator()
        end
    end

    methods
        function success=validate(~,functionHandle)
            listOfSpecialFunctions=FunctionApproximation.internal.ProblemDefinitionFactory.getMathFunctionStrings;
            functionHandle=FunctionApproximation.internal.ProblemDefinitionFactory.getFunctionHandleForSpecialFunction(functionHandle);
            handleGenerator=FunctionApproximation.internal.StandardFunctionHandleGenerator(functionHandle);
            functionString=extractFunctionName(handleGenerator);
            if ismember(functionString,listOfSpecialFunctions)
                success=true;
            else
                success=false;
            end
        end
    end
end
