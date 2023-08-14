classdef(Sealed)RelativeErrorCalculator<fixed.internal.errorcalculator.ErrorCalculator







    methods
        function result=calculate(~,approximateValue,trueValue,canComputeInDouble,bitsOfAccuracy)
            absoluteErrorCalculator=fixed.internal.errorcalculator.ErrorCalculatorFactory().getCalculatorForAbsoluteError();
            absErrResult=absoluteErrorCalculator.calculate(approximateValue,trueValue,canComputeInDouble);
            result=fixed.internal.errorcalculator.RelativeErrorCalculatorResult();
            result.transferData(absErrResult);
            result.RelativeErrorBitsOfAccuracy=bitsOfAccuracy;

            tempValues=result.AbsoluteErrorInDouble;
            falseInfs=isinf(tempValues)&~result.AbsoluteErrorValueTypes.Infs;
            tempValues(falseInfs)=realmax('double');
            numeratorValueType=fixed.internal.errorcalculator.RelativeErrorValueTypes(tempValues);
            denominatorValueType=fixed.internal.errorcalculator.RelativeErrorValueTypes(trueValue);
            valueTypes=numeratorValueType.divide(denominatorValueType);
            result.RelativeErrorValueTypes=valueTypes;

            indicesForFinites=result.RelativeErrorValueTypes.Finites;
            indicesForFinitesNonZeros=result.RelativeErrorValueTypes.FiniteNonZeros;


            if any(indicesForFinites,'all')
                if any(indicesForFinitesNonZeros,'all')
                    denominator=fixed.internal.math.fullPrecisionAbs(trueValue(indicesForFinitesNonZeros));

                    if isa(result.AbsoluteError,'double')



                        numerator=result.AbsoluteError(indicesForFinitesNonZeros);
                        relativeError=fixed.internal.errorcalculator.fullDivideInDouble(numerator,denominator);
                    else


                        numerator=fixed.internal.type.tightFi(result.AbsoluteError(indicesForFinitesNonZeros));
                        denominator=fixed.internal.math.fullSlopeBiasToBinPt(denominator);
                        denominator=fixed.internal.type.tightFi(denominator,65535);

                        w1=numerator.WordLength;
                        f1=numerator.FixedExponent;
                        w2=denominator.WordLength;
                        f2=denominator.FixedExponent;

                        log2MaxFiniteValue=w1+f1-f2;
                        log2MinFiniteValue=f1-f2-w2;
                        fractionLength=bitsOfAccuracy-log2MinFiniteValue;
                        nt=numerictype(0,log2MaxFiniteValue+fractionLength,fractionLength);
                        relativeError=fixed.internal.type.tightFi(nt.divide(numerator,denominator));


                    end
                else
                    relativeError=0;
                end
                result.RelativeError=zeros(size(trueValue),'like',relativeError);
                result.RelativeError(indicesForFinitesNonZeros)=relativeError;
            else
                result.RelativeError=zeros(size(trueValue));
            end
            result.RelativeErrorInDouble=double(result.RelativeError);
            result.RelativeErrorInDouble(valueTypes.NaNs)=NaN;
            result.RelativeErrorInDouble(valueTypes.Infs)=Inf;
            result.RelativeErrorInDouble(valueTypes.Zeros)=0;
        end
    end
end
