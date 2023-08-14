classdef ApproximateWrapperFactory<handle





    methods(Static)
        function wrapper=getApproximationWrapper(options,data)
            if options.ApproximateSolutionType==FunctionApproximation.internal.ApproximateSolutionType.Simulink
                wrapper=FunctionApproximation.internal.functionwrapper.BlockWrapper(data);
            else
                wrapper=FunctionApproximation.internal.functionwrapper.MatlabScriptWrapper(data);
            end
        end
    end
end