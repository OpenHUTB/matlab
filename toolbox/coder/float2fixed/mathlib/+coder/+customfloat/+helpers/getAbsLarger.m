%#codegen




function[larger_Sign,larger_Exponent,larger_Mantissa,...
    smaller_Sign,smaller_Exponent,smaller_Mantissa]=getAbsLarger(aSign,aExponent,aMantissa,...
    bSign,bExponent,bMantissa)

    coder.allowpcode('plain');

    if(bitconcat(aExponent,aMantissa)>=bitconcat(bExponent,bMantissa))
        larger_Sign=aSign;
        larger_Exponent=aExponent;
        larger_Mantissa=aMantissa;
        smaller_Sign=bSign;
        smaller_Exponent=bExponent;
        smaller_Mantissa=bMantissa;
    else
        larger_Sign=bSign;
        larger_Exponent=bExponent;
        larger_Mantissa=bMantissa;
        smaller_Sign=aSign;
        smaller_Exponent=aExponent;
        smaller_Mantissa=aMantissa;
    end
end