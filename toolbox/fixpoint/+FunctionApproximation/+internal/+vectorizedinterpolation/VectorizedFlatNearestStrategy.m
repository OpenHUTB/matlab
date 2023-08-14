classdef VectorizedFlatNearestStrategy<FunctionApproximation.internal.vectorizedinterpolation.VectorizedInterpolationStrategy




    methods(Static)
        function interpLogicString=getInterpolationLogicString(context)

            if context.TableValuesType.isscalingslopebias
                interpLogicString=FunctionApproximation.internal.vectorizedinterpolation.LogicStringForVectorizedFlatNearestFixedSlopeBias.getInterpolationLogicString(context.NumberOfInputs);
            else
                interpLogicString=FunctionApproximation.internal.vectorizedinterpolation.LogicStringForVectorizedFlatNearest.getInterpolationLogicString(context.NumberOfInputs);
            end
        end
    end
end
