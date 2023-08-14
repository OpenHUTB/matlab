%#codegen





function[ExponentCorrected,MantissaAppended]=appendMantissaAndCorrectExponent(Exponent,Mantissa)
    coder.allowpcode('plain');

    Exponent_Inf_or_NaN=uint16(31);


    if(Exponent==0)||(Exponent==Exponent_Inf_or_NaN)
        MantissaAppended=Mantissa;
    else
        MantissaAppended=bitor(uint16(1024),Mantissa);
    end


    if(Exponent==0)
        ExponentCorrected=uint16(1);
    else
        ExponentCorrected=Exponent;
    end
end
