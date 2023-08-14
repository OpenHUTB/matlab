classdef VectorizedPrelookupStrategyFactory<handle



    methods(Static)
        function strategy=getPrelookupStrategy(interpolationMethod)

            if interpolationMethod==FunctionApproximation.InterpolationMethod.Linear
                strategy=FunctionApproximation.internal.vectorizedprelookupfunction.VectorizedLinearPrelookupFunctionStrategy();
            elseif interpolationMethod==FunctionApproximation.InterpolationMethod.Flat
                strategy=FunctionApproximation.internal.vectorizedprelookupfunction.VectorizedFlatPrelookupFunctionStrategy();
            elseif interpolationMethod==FunctionApproximation.InterpolationMethod.Nearest
                strategy=FunctionApproximation.internal.vectorizedprelookupfunction.VectorizedNearestPrelookupFunctionStrategy();
            end
        end
    end
end


