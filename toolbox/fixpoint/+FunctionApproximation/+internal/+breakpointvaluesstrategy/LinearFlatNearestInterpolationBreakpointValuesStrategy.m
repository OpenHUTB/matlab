classdef LinearFlatNearestInterpolationBreakpointValuesStrategy<FunctionApproximation.internal.breakpointvaluesstrategy.BreakpointValuesStrategy




    methods(Static)
        function breakpointValuesString=getString(context)

            breakpointValuesString=convertStringsToChars(strings(numel(context.BreakpointValues),1));
            useFromVariableStrategy=prod(cellfun(@length,context.BreakpointValues))>=1000;

            for i=1:numel(context.BreakpointValues)

                if useFromVariableStrategy&&~context.BreakpointValuesType(i).isscalingslopebias
                    breakpointValuesString{i}=FunctionApproximation.internal.breakpointvaluesstrategy.BreakpointValuesFromVariable.getBreakpointValuesString(i);
                elseif useFromVariableStrategy&&context.BreakpointValuesType(i).isscalingslopebias
                    breakpointValuesString{i}=FunctionApproximation.internal.breakpointvaluesstrategy.BreakpointValuesFromVariableFixedSlopeBias.getBreakpointValuesString(i);
                else


                    if context.BreakpointValuesType(i).isscalingbinarypoint
                        breakpointValuesString{i}=FunctionApproximation.internal.breakpointvaluesstrategy.BreakpointValuesStringForFixed.getBreakpointValuesString(context.BreakpointValues,context.BreakpointValuesType(i),i);
                    elseif context.BreakpointValuesType(i).isscalingslopebias
                        breakpointValuesString{i}=FunctionApproximation.internal.breakpointvaluesstrategy.BreakpointValuesStringForFixedSlopeBias.getBreakpointValuesString(context.BreakpointValues,context.BreakpointValuesType(i),context.InputType(i),i);
                    elseif context.BreakpointValuesType(i).isfloat
                        if ishalf(context.BreakpointValuesType(i))
                            context.BreakpointValuesType(i)=numerictype('single');
                        end
                        breakpointValuesString{i}=FunctionApproximation.internal.breakpointvaluesstrategy.BreakpointValuesStringForFloat.getBreakpointValuesString(context.BreakpointValues,context.BreakpointValuesType(i),i);
                    end
                end




                if~strcmp(context.BreakpointValuesType(i).DataType,context.InputType(i).DataType)
                    commentStr=message('SimulinkFixedPoint:functionApproximation:mlutCastToInputValue').getString();
                    breakpointValuesString{i}=[breakpointValuesString{i},newline,commentStr,newline,'breakpointValues',num2str(i),' = cast(breakpointValues',num2str(i),',''like'',',mat2str(fixed.internal.math.castUniversal([],context.InputType(i).DataType),'class'),');',newline];
                end



                if~isempty(breakpointValuesString{i})
                    if context.Spacing==0||context.Spacing==1


                        breakpointValues=context.BreakpointValues{i};

                        bpSpaceReciprocalString=['bpSpaceReciprocal',num2str(i),' = ',mat2str(1./(breakpointValues(2)-breakpointValues(1))),';'];

                        breakpointValuesString{i}=[breakpointValuesString{i},newline,bpSpaceReciprocalString,newline];
                    end
                    if context.Spacing==1


                        bpSpaceString=FunctionApproximation.internal.breakpointvaluesstrategy.BreakpointPowTwoSpacingString.getBreakpointSpacingString(context.BreakpointValues,i);
                        breakpointValuesString{i}=[breakpointValuesString{i},newline,bpSpaceString,newline];
                    end
                end
            end

            breakpointValuesString=[breakpointValuesString{:}];
        end
    end
end


