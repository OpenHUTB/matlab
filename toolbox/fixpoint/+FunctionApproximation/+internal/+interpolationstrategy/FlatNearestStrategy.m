classdef FlatNearestStrategy<FunctionApproximation.internal.interpolationstrategy.InterpolationStrategy




    methods(Static)
        function interpLogicString=getInterpolationLogicString(context)

            if context.TableValuesType.isscalingslopebias
                interpLogicString=FunctionApproximation.internal.interpolationstrategy.LogicStringForFlatNearestFixedSlopeBias.getInterpolationLogicString(context.NumberOfInputs);
            else
                interpLogicString=FunctionApproximation.internal.interpolationstrategy.LogicStringForFlatNearest.getInterpolationLogicString(context.NumberOfInputs);
            end
        end
    end
end
