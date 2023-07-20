%#codegen



function[Exponent,Mantissa]=checkDenormal(cfType,inExponent,inMantissa,denormal)
    coder.allowpcode('plain');

    Exponent=inExponent;

    if(denormal)
        Mantissa=inMantissa;
    else
        if(inExponent==0)
            Mantissa=fi(0,0,cfType.MantissaLength,0);
        else
            Mantissa=inMantissa;
        end
    end
end