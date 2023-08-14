classdef StringToDefineDenominatorReciprocalForFloat<FunctionApproximation.internal.denominatorreciprocalstring.StringToDefineDenominatorReciprocal





    methods(Static)
        function string=getStringToDefineDenominator(denominatorReciprocalType)
            string=['denominatorReciprocal = fi(0,',denominatorReciprocalType.tostring,');'];
        end
    end
end