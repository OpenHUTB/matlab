%#codegen






function[Sign,Exponent,Mantissa]=times(cfType,aSign,aExponent,aMantissa,bSign,bExponent,bMantissa,denormal)
    coder.allowpcode('plain');

    Sign=bitxor(aSign,bSign);

    [aExponent,aMantissa]=coder.customfloat.helpers.checkDenormal(cfType,aExponent,aMantissa,denormal);
    [bExponent,bMantissa]=coder.customfloat.helpers.checkDenormal(cfType,bExponent,bMantissa,denormal);


    aExpInforNaN=(aExponent==cfType.Exponent_Inf_or_NaN);
    bExpInforNaN=(bExponent==cfType.Exponent_Inf_or_NaN);
    aMantZero=(aMantissa==0);
    bMantZero=(bMantissa==0);
    aIsZero=((aExponent==0)&&(aMantZero));
    bIsZero=((bExponent==0)&&(bMantZero));


    if(aExpInforNaN)||(bExpInforNaN)
        [Sign,Exponent,Mantissa]=times_Inf_or_NaN(cfType,Sign,aSign,aMantissa,...
        bSign,bMantissa,...
        aExpInforNaN,aMantZero,aIsZero,...
        bExpInforNaN,bMantZero,bIsZero);
    elseif(aIsZero)||(bIsZero)

        Exponent=fi(0,0,cfType.ExponentLength,0);
        Mantissa=fi(0,0,cfType.MantissaLength,0);
    else

        [exp_a_cor,mant_a_cor]=coder.customfloat.helpers.appendMantissaAndCorrectExponent(cfType,aExponent,aMantissa);
        [exp_b_cor,mant_b_cor]=coder.customfloat.helpers.appendMantissaAndCorrectExponent(cfType,bExponent,bMantissa);

        [Exponent,Mantissa]=times_Main(cfType,exp_a_cor,mant_a_cor,exp_b_cor,mant_b_cor,denormal);
    end

end



function[Sign,Exponent,Mantissa]=times_Inf_or_NaN(cfType,Sign,aSign,aMantissa,...
    bSign,bMantissa,...
    aExpInforNaN,aMantZero,aIsZero,...
    bExpInforNaN,bMantZero,bIsZero)
    Exponent=cfType.Exponent_Inf_or_NaN;

    if(aExpInforNaN)
        Mantissa=aMantissa;

        if(~aMantZero)
            Sign=aSign;
        elseif(bIsZero||((~bMantZero)&&bExpInforNaN))
            Mantissa=cfType.Mantissa_NaN;
        end
    else
        Mantissa=bMantissa;

        if(~bMantZero)
            Sign=bSign;
        elseif(aIsZero||((~aMantZero)&&aExpInforNaN))
            Mantissa=cfType.Mantissa_NaN;
        end
    end
end



function[Exponent,Mantissa]=times_Main(cfType,exp_a_cor,mant_a_cor,exp_b_cor,mant_b_cor,denormal)



    [exp_a_norm,mant_a_norm]=times_Normalize_Exp_Mant(cfType,exp_a_cor,mant_a_cor,denormal);
    [exp_b_norm,mant_b_norm]=times_Normalize_Exp_Mant(cfType,exp_b_cor,mant_b_cor,denormal);








    exp_sum=cast(exp_a_norm+exp_b_norm,'like',exp_a_norm);

    [exp_out,mant_ext,sticky]=times_Product(cfType,mant_a_norm,mant_b_norm,exp_sum);





    [exp_norm,mant_norm,sticky]=times_Normalize(cfType,exp_out,mant_ext,sticky,denormal);


    if(denormal)
        [Exponent,Mantissa]=coder.customfloat.helpers.rounding(exp_norm,mant_norm,sticky);
    else
        [Exponent,Mantissa]=coder.customfloat.helpers.rounding_normals(exp_norm,mant_norm,sticky);
    end
end





function[exp_norm,mant_norm]=times_Normalize_Exp_Mant(cfType,exp_cor,mant_cor,denormal)
    if(denormal)
        [exp_norm,mant_norm]=times_Normalize_Exp_Mant_Denormal(cfType,exp_cor,mant_cor);
    else
        [exp_norm,mant_norm]=times_Normalize_Exp_Mant_Normal(cfType,exp_cor,mant_cor);
    end
end



function[exp_norm,mant_norm]=times_Normalize_Exp_Mant_Denormal(cfType,exp_a,mant_a)
    if(bitget(mant_a,mant_a.WordLength)==0)
        ia=int8(mant_a.WordLength)-int8(coder.customfloat.helpers.findFirst1(mant_a));
        exp_norm=fi(1-ia,1,cfType.ExponentLength+3,0);
        mant_a(:)=bitsll(mant_a,ia);
    else
        exp_norm=fi(exp_a,1,cfType.ExponentLength+3,0);
    end

    mant_norm=reinterpretcast(mant_a,numerictype(0,cfType.MantissaLength+1,cfType.MantissaLength));
end



function[exp_norm,mant_norm]=times_Normalize_Exp_Mant_Normal(cfType,exp_a,mant_a)
    exp_norm=fi(exp_a,1,cfType.ExponentLength+3,0);
    mant_norm=reinterpretcast(mant_a,numerictype(0,cfType.MantissaLength+1,cfType.MantissaLength));

end





function[exp_out,mant_out,sticky]=times_Product(cfType,mant_a_norm,mant_b_norm,exp_sum)
    mant_ext=mant_a_norm*mant_b_norm;

    sticky=(bitsliceget(mant_ext,cfType.MantissaLength-1,1)~=0);

    if bitget(mant_ext,mant_ext.WordLength)
        exp_out=cast(exp_sum-cfType.ExponentBias+cast(1,'like',exp_sum),'like',exp_sum);
        mant_out=bitsliceget(mant_ext,mant_ext.WordLength,mant_ext.WordLength-cfType.MantissaLength-1);
        sticky=(sticky||bitget(mant_ext,mant_ext.WordLength-cfType.MantissaLength-2));
    else
        exp_out=cast(exp_sum-cfType.ExponentBias,'like',exp_sum);
        mant_out=bitsliceget(mant_ext,mant_ext.WordLength-1,mant_ext.WordLength-cfType.MantissaLength-2);
    end
end















function[exp,mant,sticky]=times_Normalize(cfType,exp_out,mant_ext,sticky,denormal)
    if(denormal)
        [exp,mant,sticky]=times_Normalize_Denormals(cfType,exp_out,mant_ext,sticky);
    else
        [exp,mant,sticky]=times_Normalize_Normals(cfType,exp_out,mant_ext,sticky);
    end
end

function[exp,mant,sticky]=times_Normalize_Denormals(cfType,exp_out,mant_ext,sticky)


    if(exp_out>=cast(cfType.Exponent_Inf_or_NaN,'like',exp_out))

        exp=cfType.Exponent_Inf_or_NaN;
        mant=fi(0,0,cfType.MantissaLength+1,0);
    elseif(exp_out<-cfType.MantissaLength)

        exp=fi(0,0,cfType.ExponentLength,0);
        mant=fi(0,0,cfType.MantissaLength+1,0);
    else
        if(exp_out>0)

            exp=fi(exp_out,0,cfType.ExponentLength,0);
        else

            exp=fi(0,0,cfType.ExponentLength,0);

            shift_length=cast(1,'like',exp_out)-exp_out;
            sticky=(sticky||(bitsll(mant_ext,mant_ext.WordLength-shift_length)~=0));
            mant_ext(:)=bitsrl(mant_ext,shift_length);
        end

        mant=bitsliceget(mant_ext,mant_ext.WordLength-1,1);
    end
end


function[exp,mant,sticky]=times_Normalize_Normals(cfType,exp_out,mant_ext,sticky)
    if(exp_out>=cast(cfType.Exponent_Inf_or_NaN,'like',exp_out))

        exp=cfType.Exponent_Inf_or_NaN;
        mant=fi(0,0,cfType.MantissaLength+1,0);
    elseif bitget(exp_out,exp_out.WordLength)

        exp=fi(0,0,cfType.ExponentLength,0);
        mant=fi(0,0,cfType.MantissaLength+1,0);
    else
        if(exp_out==0)
            exp=fi(0,0,cfType.ExponentLength,0);
            sticky=(sticky||bitget(mant_ext,1));
            mant_ext(:)=bitsrl(mant_ext,1);
        else

            exp=fi(exp_out,0,cfType.ExponentLength,0);
        end

        mant=bitsliceget(mant_ext,mant_ext.WordLength-1,1);
    end
end
