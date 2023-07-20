classdef LinearFlatNearestInterpolationTableValuesStrategy<FunctionApproximation.internal.tablevaluesstrategy.TableValuesStrategy



    methods(Static)
        function tableValuesString=getString(context)

            tableValuesString='';
            useFromVariableStrategy=numel(context.TableValues)>=1000;


            if useFromVariableStrategy&&~context.TableValuesType.isscalingslopebias
                tableValuesString=FunctionApproximation.internal.tablevaluesstrategy.TableValuesFromVariable.getTableValuesString(context.TableValues,context.TableValuesType);
            elseif useFromVariableStrategy&&context.TableValuesType.isscalingslopebias
                tableValuesString=FunctionApproximation.internal.tablevaluesstrategy.TableValuesFromVariableFixedSlopeBias.getTableValuesString(context.TableValues,context.TableValuesType);
            else


                if context.TableValuesType.isscalingbinarypoint
                    tableValuesString=FunctionApproximation.internal.tablevaluesstrategy.TableValuesStringForFixed.getTableValuesString(context.TableValues,context.TableValuesType);
                elseif context.TableValuesType.isscalingslopebias
                    tableValuesString=FunctionApproximation.internal.tablevaluesstrategy.TableValuesStringForFixedSlopeBias.getTableValuesString(context.TableValues,context.TableValuesType);
                elseif context.TableValuesType.isfloat
                    tableValuesString=FunctionApproximation.internal.tablevaluesstrategy.TableValuesStringForFloat.getTableValuesString(context.TableValues,context.TableValuesType);
                end
            end
        end
    end
end
