function string=getStringToDefineNumerator(numeratorType)




    if numeratorType.isfloat
        string=FunctionApproximation.internal.numeratorstring.StringToDefineNumeratorForFloat.getStringToDefineNumerator(numeratorType);
    else
        string=FunctionApproximation.internal.numeratorstring.StringToDefineNumeratorForFixed.getStringToDefineNumerator(numeratorType);
    end
end
