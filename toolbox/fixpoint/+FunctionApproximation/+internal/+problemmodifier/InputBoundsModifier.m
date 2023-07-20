classdef(Sealed)InputBoundsModifier<FunctionApproximation.internal.problemmodifier.ProblemDefinitionModifier




    methods
        function problemDefinition=modify(this,problemDefinition)
            for ii=problemDefinition.NumberOfInputs:-1:1
                if~(isfixed(problemDefinition.InputTypes(ii))&&isscalingunspecified(problemDefinition.InputTypes(ii)))
                    datatype=problemDefinition.InputTypes(ii);
                    rangeValue=double(fixed.internal.type.finiteRepresentableRange(datatype));
                    minValue=rangeValue(1);
                    maxValue=rangeValue(2);
                    dtString=datatype.tostringInternalSlName();
                    if datatype.isfixed()
                        dtString=datatype.tostring();
                    end


                    lowerBound=problemDefinition.InputLowerBounds(ii);
                    if isinf(lowerBound)
                        lowerBound=minValue;
                        this.MessageRepository.addMessage(FunctionApproximation.internal.DisplayUtils.getBoundCorrectionString('SimulinkFixedPoint:functionApproximation:lowerBoundSnapped',ii,dtString,lowerBound));
                    elseif lowerBound<minValue-FunctionApproximation.internal.Utils.getMinimumAbsoluteTolerance(datatype)
                        lowerBound=minValue;
                        this.MessageRepository.addMessage(FunctionApproximation.internal.DisplayUtils.getBoundCorrectionString('SimulinkFixedPoint:functionApproximation:lowerBoundSnapped',ii,dtString,lowerBound));
                    else
                        lowerBound=double(fixed.internal.math.castUniversal(lowerBound,datatype,true,'RoundingMethod','Floor'));
                    end
                    if problemDefinition.InputLowerBounds(ii)~=lowerBound
                        problemDefinition.InputLowerBounds(ii)=lowerBound;
                        problemDefinition.BoundsModifiedToType(ii)=true;
                    end


                    upperBound=problemDefinition.InputUpperBounds(ii);
                    if isinf(upperBound)
                        upperBound=maxValue;
                        this.MessageRepository.addMessage(FunctionApproximation.internal.DisplayUtils.getBoundCorrectionString('SimulinkFixedPoint:functionApproximation:upperBoundSnapped',ii,dtString,upperBound));
                    elseif upperBound>maxValue+FunctionApproximation.internal.Utils.getMinimumAbsoluteTolerance(datatype)
                        upperBound=maxValue;
                        this.MessageRepository.addMessage(FunctionApproximation.internal.DisplayUtils.getBoundCorrectionString('SimulinkFixedPoint:functionApproximation:upperBoundSnapped',ii,dtString,upperBound));
                    else
                        upperBound=double(fixed.internal.math.castUniversal(upperBound,datatype,true,'RoundingMethod','Ceiling'));
                    end
                    if problemDefinition.InputUpperBounds(ii)~=upperBound
                        problemDefinition.InputUpperBounds(ii)=upperBound;
                        problemDefinition.BoundsModifiedToType(ii)=true;
                    end
                end
            end
        end
    end
end
