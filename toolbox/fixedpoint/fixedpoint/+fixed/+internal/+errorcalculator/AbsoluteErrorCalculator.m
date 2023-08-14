classdef(Sealed)AbsoluteErrorCalculator<fixed.internal.errorcalculator.ErrorCalculator








    methods
        function result=calculate(~,approximateValue,trueValue,canComputeInDouble)
            result=fixed.internal.errorcalculator.AbsoluteErrorCalculatorResult();
            result.TrueValue=trueValue;
            result.ApproximateValue=approximateValue;





            data=fixed.internal.errorcalculator.fullSubtract(trueValue,...
            approximateValue,canComputeInDouble);
            difference=data.diffFinite;
            result.Error=difference;
            absDiff=fixed.internal.math.fullPrecisionAbs(difference);
            result.AbsoluteError=absDiff;
            approxValueTypes=fixed.internal.errorcalculator.AbsoluteErrorValueTypes(approximateValue);
            trueValueTypes=fixed.internal.errorcalculator.AbsoluteErrorValueTypes(trueValue);
            valueTypes=trueValueTypes.subtract(approxValueTypes);
            result.AbsoluteErrorInDouble=double(result.AbsoluteError);
            result.AbsoluteErrorInDouble(valueTypes.Infs)=inf;
            result.AbsoluteErrorInDouble(valueTypes.NaNs)=nan;




            result.AbsoluteErrorInDouble(valueTypes.Zeros)=0.0;
            result.AbsoluteErrorValueTypes=valueTypes;

            result.ErrorInDouble=double(result.Error);
            result.ErrorInDouble(valueTypes.PosInfs)=inf;
            result.ErrorInDouble(valueTypes.NegInfs)=-inf;
            result.ErrorInDouble(valueTypes.NaNs)=nan;
            result.ErrorInDouble(valueTypes.Zeros)=0.0;
        end
    end
end
