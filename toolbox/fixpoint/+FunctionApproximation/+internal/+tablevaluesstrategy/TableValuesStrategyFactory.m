classdef TableValuesStrategyFactory<handle



    methods(Static)
        function strategy=getStrategy(~)

            strategy=FunctionApproximation.internal.tablevaluesstrategy.LinearFlatNearestInterpolationTableValuesStrategy();
        end
    end
end