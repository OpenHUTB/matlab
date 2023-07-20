classdef StringToDefineNumeratorForFloat<FunctionApproximation.internal.numeratorstring.StringToDefineNumerator




    methods(Static)
        function string=getStringToDefineNumerator(numeratorType)
            string=['numerator = ',mat2str(fixed.internal.math.castUniversal(0,numeratorType),'class'),';'];
        end
    end
end
