classdef PrelookupStrategyFactory<handle



    methods(Static)
        function strategy=getPrelookupStrategy(interpolationMethod)

            if interpolationMethod==FunctionApproximation.InterpolationMethod.Linear
                strategy=FunctionApproximation.internal.prelookupfunction.LinearPrelookupFunctionStrategy();
            elseif interpolationMethod==FunctionApproximation.InterpolationMethod.Flat
                strategy=FunctionApproximation.internal.prelookupfunction.FlatPrelookupFunctionStrategy();
            elseif interpolationMethod==FunctionApproximation.InterpolationMethod.Nearest
                strategy=FunctionApproximation.internal.prelookupfunction.NearestPrelookupFunctionStrategy();
            end
        end
    end
end


