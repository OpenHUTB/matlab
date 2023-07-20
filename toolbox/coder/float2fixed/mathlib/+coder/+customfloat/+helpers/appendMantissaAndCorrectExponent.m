%#codegen






function[ExponentCorrected,MantissaAppended]=appendMantissaAndCorrectExponent(cfType,Exponent,Mantissa)
    coder.allowpcode('plain');
    if(Exponent==0)||(cfType.Exponent_Inf_or_NaN==Exponent)
        MantissaAppended=bitconcat(fi(0,0,1,0),Mantissa);
    else
        MantissaAppended=bitconcat(fi(1,0,1,0),Mantissa);
    end

    if(Exponent==0)
        ExponentCorrected=cast(1,'like',Exponent);
    else
        ExponentCorrected=Exponent;
    end
end
