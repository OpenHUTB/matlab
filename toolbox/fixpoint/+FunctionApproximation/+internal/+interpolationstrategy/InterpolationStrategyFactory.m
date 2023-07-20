classdef InterpolationStrategyFactory<handle



    methods(Static)
        function strategy=getInterpolationStrategy(interpolationMethod)

            if interpolationMethod==FunctionApproximation.InterpolationMethod.Linear
                strategy=FunctionApproximation.internal.interpolationstrategy.LinearPointSlopeStrategy;
            else
                strategy=FunctionApproximation.internal.interpolationstrategy.FlatNearestStrategy;
            end
        end
    end
end
