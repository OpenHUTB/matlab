classdef(Sealed)DLCodegenErrorHandlerDispatcher<handle




    methods(Static)
        function errorHandler=dispatchHandler(logAllErrors)
            if logAllErrors
                errorHandler=coder.internal.DLCodegenCompatibilityLogger;
            else
                errorHandler=coder.internal.DLCodegenErrorThrower;
            end
        end
    end
end
