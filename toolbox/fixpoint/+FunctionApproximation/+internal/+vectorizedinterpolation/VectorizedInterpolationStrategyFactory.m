classdef VectorizedInterpolationStrategyFactory<handle




    methods(Static)
        function strategy=getInterpolationStrategy(interpolationMethod)

            if interpolationMethod==FunctionApproximation.InterpolationMethod.Linear
                strategy=FunctionApproximation.internal.vectorizedinterpolation.VectorizedLinearPointSlopeStrategy();
            else
                strategy=FunctionApproximation.internal.vectorizedinterpolation.VectorizedFlatNearestStrategy();
            end
        end
    end
end
