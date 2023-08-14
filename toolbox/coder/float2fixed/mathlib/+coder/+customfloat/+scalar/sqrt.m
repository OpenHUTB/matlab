%#codegen






function[Sign,Exponent,Mantissa]=sqrt(cfType,aSign,aExponent,aMantissa)
    coder.allowpcode('plain');

    Sign=aSign;

    if(aExponent==0)&&(aMantissa==0)
        Sign=fi(0,0,1,0);
        Exponent=fi(0,0,cfType.ExponentLength,0);
        Mantissa=fi(0,0,cfType.MantissaLength,0);
    elseif(aSign==1)||(cfType.Exponent_Inf_or_NaN==aExponent)
        [Exponent,Mantissa]=sqrt_Inf_or_NaN(cfType,aSign,aExponent,aMantissa);
    else
        [exp_a_cor,mant_a_cor]=coder.customfloat.helpers.appendMantissaAndCorrectExponent(cfType,aExponent,aMantissa);
        [Exponent,Mantissa]=sqrt_Long(cfType,exp_a_cor,mant_a_cor);
    end
end

function[Exponent,Mantissa]=sqrt_Long(cfType,exp_a_cor,mant_a_cor)

    [Exp,mant_a_norm]=sqrt_Normalize(cfType,exp_a_cor,mant_a_cor);

    Q=fi(0,1,cfType.MantissaLength+5,0);
    Q(:)=bitset(Q,cfType.MantissaLength+2,1);
    R=fi(mant_a_norm-Q,1,cfType.MantissaLength+5,0);

    for ii=coder.unroll(int8(cfType.MantissaLength+1):-1:1)
        [Q,R]=sqrt_Long_get_digit(Q,R,ii);
    end

    sticky=(R~=0);

    [Exponent,Mantissa]=coder.customfloat.helpers.rounding(Exp,bitsliceget(Q,cfType.MantissaLength+1,1),sticky);
end

function[Q,R]=sqrt_Long_get_digit(Q,R,ii)
    R(:)=bitsll(R,1);

    tmp1=bitsll(Q,1);
    tmp2=bitset(tmp1,ii,1);
    tmp3=cast(R-tmp2,'like',R);

    if(tmp3>=0)
        Q(:)=bitset(Q,ii,1);
        R(:)=tmp3;
    end
end

function[Exponent,mant_a_norm]=sqrt_Normalize(cfType,exp_a_cor,mant_a_cor)










    pos=coder.customfloat.helpers.findFirst1(mant_a_cor);
    shift_length=uint8(mant_a_cor.WordLength)-pos;

    exp_a_norm=fi(exp_a_cor+fi(cfType.ExponentBias,0,cfType.ExponentLength+1,0)...
    -shift_length,0,cfType.ExponentLength+1,0);

    if bitget(exp_a_norm,1)
        shift_length(:)=shift_length+uint8(1);
    end

    Exponent=bitsliceget(exp_a_norm,cfType.ExponentLength+1,2);

    mant_a_tmp=bitconcat(fi(0,0,3,0),mant_a_cor,fi(0,0,1,0));
    mant_a_tmp1=bitsll(mant_a_tmp,shift_length);
    mant_a_norm=reinterpretcast(mant_a_tmp1,numerictype(1,cfType.MantissaLength+5,0));
end

function[Exponent,Mantissa]=sqrt_Inf_or_NaN(cfType,aSign,aExponent,aMantissa)
    if(aSign==0)&&(aExponent==cfType.Exponent_Inf_or_NaN)&&(aMantissa==0)

        Exponent=aExponent;
        Mantissa=aMantissa;
    else
        Exponent=cfType.Exponent_Inf_or_NaN;
        Mantissa=cfType.Mantissa_NaN;
    end
end
