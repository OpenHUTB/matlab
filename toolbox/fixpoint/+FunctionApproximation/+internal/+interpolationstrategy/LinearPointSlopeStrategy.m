classdef LinearPointSlopeStrategy<FunctionApproximation.internal.interpolationstrategy.InterpolationStrategy




    methods(Static)
        function interpLogicString=getInterpolationLogicString(context)



            if(context.TableValuesType.isscalingslopebias||context.TableValuesType.isscalingbinarypoint)&&~context.OutputType.Signed&&~context.TableValuesType.Signed
                interpLogicString=FunctionApproximation.internal.interpolationstrategy.LogicStringForOutputUnsignedFixed.getInterpolationLogicString(context.NumberOfInputs);
            elseif context.TableValuesType.isscalingslopebias
                interpLogicString=FunctionApproximation.internal.interpolationstrategy.LogicStringForOutputFixedSlopeBias.getInterpolationLogicString(context.NumberOfInputs);
            else
                interpLogicString=FunctionApproximation.internal.interpolationstrategy.LogicStringForOutput.getInterpolationLogicString(context.NumberOfInputs);
            end
        end
    end
end




