classdef(Sealed)GenericFunctionHandleValidator<FunctionApproximation.internal.utilities.ValidatorInterface





    methods(Access=?FunctionApproximation.internal.AbstractUtils)

        function this=GenericFunctionHandleValidator()
        end
    end

    methods
        function success=validate(~,functionHandle)
            try
                nInputs=nargin(functionHandle);
                inputValues=num2cell(ones(1,nInputs));





                functionHandle(inputValues{:});

                success=true;
            catch
                success=false;
            end
        end
    end
end
