classdef StringToDefineDenominatorReciprocalForFixed<FunctionApproximation.internal.denominatorreciprocalstring.StringToDefineDenominatorReciprocal





    methods(Static)
        function string=getStringToDefineDenominator(denominatorReciprocalType)
            if isfi(denominatorReciprocalType)
                denominatorReciprocalType.Value='0';
            else
                denominatorReciprocalType=fi(0,denominatorReciprocalType);
            end
            string=['denominatorReciprocal = coder.const(',denominatorReciprocalType.tostring,');'];
        end
    end
end
