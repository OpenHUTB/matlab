%#codegen



function[Sign,Exponent,Mantissa]=ceil(cfType,inSign,inExponent,inMantissa)

    coder.allowpcode('plain');

    Sign=inSign;

    if(inExponent>=cfType.ExponentBias+cfType.MantissaLength)||...
        ((inExponent==0)&&(inMantissa==0))

        Exponent=inExponent;
        Mantissa=inMantissa;
    elseif inExponent<cfType.ExponentBias

        Mantissa=fi(0,0,cfType.MantissaLength,0);

        if(inSign)

            Exponent=fi(0,0,cfType.ExponentLength,0);
        else

            Exponent=fi(cfType.ExponentBias,0,cfType.ExponentLength,0);
        end
    else
        pos=coder.customfloat.helpers.findLast1(bitconcat(fi(1,0,1,0),inMantissa));

        ONE=fi(1,0,cfType.ExponentLength+cfType.MantissaLength,0);
        shift_length=fi(cfType.MantissaLength,0,cfType.ExponentLength,0)-(inExponent-fi(cfType.ExponentBias,0,cfType.ExponentLength,0));
        ONE(:)=bitsll(ONE,shift_length);
        MASK=bitcmp(fi(ONE-cast(1,'like',ONE),0,cfType.ExponentLength+cfType.MantissaLength,0));

        tmp=bitconcat(inExponent,inMantissa);
        tmp(:)=bitand(tmp,MASK);

        if((pos<=shift_length)&&(inSign==0))
            tmp(:)=tmp+ONE;
        end

        Exponent=bitsliceget(tmp,tmp.WordLength,tmp.WordLength-cfType.ExponentLength+1);
        Mantissa=bitsliceget(tmp,cfType.MantissaLength,1);
    end

end
