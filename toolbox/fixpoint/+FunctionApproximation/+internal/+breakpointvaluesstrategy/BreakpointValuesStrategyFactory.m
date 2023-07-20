classdef BreakpointValuesStrategyFactory<handle



    methods(Static)
        function strategy=getStrategy(~)


            strategy=FunctionApproximation.internal.breakpointvaluesstrategy.LinearFlatNearestInterpolationBreakpointValuesStrategy();

        end
    end
end
