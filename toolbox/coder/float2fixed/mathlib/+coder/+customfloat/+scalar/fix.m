%#codegen



function[Sign,Exponent,Mantissa]=fix(cfType,inSign,inExponent,inMantissa)

    coder.allowpcode('plain');

    Sign=inSign;

    if(inExponent>=cfType.ExponentBias+cfType.MantissaLength)||...
        ((inExponent==0)&&(inMantissa==0))

        Exponent=inExponent;
        Mantissa=inMantissa;
    elseif inExponent<cfType.ExponentBias

        Exponent=fi(0,0,cfType.ExponentLength,0);
        Mantissa=fi(0,0,cfType.MantissaLength,0);
    else
        Exponent=inExponent;



        ONE=fi(1,0,cfType.MantissaLength+1,0);
        shift_length=fi(cfType.MantissaLength,0,cfType.ExponentLength,0)-(inExponent-fi(cfType.ExponentBias,0,cfType.ExponentLength,0));
        ONE(:)=bitsll(ONE,shift_length);
        MASK=bitcmp(fi(ONE-cast(1,'like',ONE),0,cfType.MantissaLength,0));

        Mantissa=inMantissa;
        Mantissa(:)=bitand(Mantissa,MASK);

    end

end
