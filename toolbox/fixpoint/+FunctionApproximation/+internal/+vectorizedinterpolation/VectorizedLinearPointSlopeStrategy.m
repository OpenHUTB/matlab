classdef VectorizedLinearPointSlopeStrategy<FunctionApproximation.internal.vectorizedinterpolation.VectorizedInterpolationStrategy




    methods(Static)
        function interpLogicString=getInterpolationLogicString(context)



            if~context.OutputType.Signed&&~context.TableValuesType.Signed
                interpLogicString=FunctionApproximation.internal.vectorizedinterpolation.LogicStringForVectorizedNonMonotonicOutput.getInterpolationLogicString(context.NumberOfInputs);
            elseif context.TableValuesType.isscalingslopebias
                interpLogicString=FunctionApproximation.internal.vectorizedinterpolation.LogicStringForVectorizedSlopeBiasOutput.getInterpolationLogicString(context.NumberOfInputs);
            else
                interpLogicString=FunctionApproximation.internal.vectorizedinterpolation.LogicStringForVectorizedOutput.getInterpolationLogicString(context.NumberOfInputs);
            end
        end
    end
end




