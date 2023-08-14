function string=getStringToDefineDenominatorReciprocal(denominatorReciprocalType)





    if denominatorReciprocalType.isfloat
        string=FunctionApproximation.internal.denominatorreciprocalstring.StringToDefineDenominatorReciprocalForFloat.getStringToDefineDenominator(denominatorReciprocalType);
    else
        string=FunctionApproximation.internal.denominatorreciprocalstring.StringToDefineDenominatorReciprocalForFixed.getStringToDefineDenominator(denominatorReciprocalType);
    end
end
