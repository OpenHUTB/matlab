classdef StringToDefineNumeratorForFixed<FunctionApproximation.internal.numeratorstring.StringToDefineNumerator





    methods(Static)
        function string=getStringToDefineNumerator(numeratorType)
            if isfi(numeratorType)
                numeratorType.Value='0';
            else
                numeratorType=fi(0,numeratorType);
            end
            string=['numerator = coder.const(',numeratorType.tostring,');'];
        end
    end
end
