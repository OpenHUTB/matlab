%#codegen






function[Sign,Exponent,Mantissa]=rdivide(cfType,aSign,aExponent,aMantissa,bSign,bExponent,bMantissa,denormal)
    coder.allowpcode('plain');

    [aExponent,aMantissa]=coder.customfloat.helpers.checkDenormal(cfType,aExponent,aMantissa,denormal);
    [bExponent,bMantissa]=coder.customfloat.helpers.checkDenormal(cfType,bExponent,bMantissa,denormal);


    Sign=bitxor(aSign,bSign);


    if(aExponent==cfType.Exponent_Inf_or_NaN)||(bExponent==cfType.Exponent_Inf_or_NaN)
        [Exponent,Mantissa]=rdivide_Inf_or_NaN(cfType,aExponent,aMantissa,bExponent,bMantissa);
    elseif(aExponent==0)&&(aMantissa==0)
        if(bExponent==0)&&(bMantissa==0)

            Exponent=cfType.Exponent_Inf_or_NaN;
            Mantissa=cfType.Mantissa_NaN;
        else
            Exponent=fi(0,0,cfType.ExponentLength,0);
            Mantissa=fi(0,0,cfType.MantissaLength,0);
        end
    elseif(bExponent==0)&&(bMantissa==0)

        Exponent=cfType.Exponent_Inf_or_NaN;
        Mantissa=fi(0,0,cfType.MantissaLength,0);
    else
        [exp_a_cor,mant_a_cor]=coder.customfloat.helpers.appendMantissaAndCorrectExponent(cfType,aExponent,aMantissa);
        [exp_b_cor,mant_b_cor]=coder.customfloat.helpers.appendMantissaAndCorrectExponent(cfType,bExponent,bMantissa);
        [Exponent,Mantissa]=rdivide_Normal_Long_Div(cfType,exp_a_cor,mant_a_cor,exp_b_cor,mant_b_cor,denormal);
    end

end


function[exp,mant]=rdivide_Normal_Long_Div(cfType,exp_a,mant_a,exp_b,mant_b,denormal)



    [exp_a_norm,mant_a_norm,exp_b_norm,mant_b_norm]=rdivide_Normalize_Exp_Mant(cfType,exp_a,mant_a,exp_b,mant_b,denormal);





    [exp_c,shift_length]=rdivide_Extract_Exp(cfType,exp_a_norm,exp_b_norm,denormal);





    [Q,R]=rdivide_Long_Div(mant_a_norm,mant_b_norm,cfType.MantissaLength);


    [mant_norm,sticky]=rdivide_Normalize(cfType,Q,R,shift_length,denormal);


    if(denormal)
        [exp,mant]=coder.customfloat.helpers.rounding(exp_c,mant_norm,sticky);
    else
        [exp,mant]=coder.customfloat.helpers.rounding_normals(exp_c,mant_norm,sticky);
    end

end


function[mant,sticky]=rdivide_Normalize(cfType,Q,R,shift_length,denormal)
    if(denormal)
        [mant,sticky]=rdivide_Normalize_Denormals(cfType,Q,R,shift_length);
    else
        [mant,sticky]=rdivide_Normalize_Normals(cfType,Q,R,shift_length);
    end
end

function[mant,sticky]=rdivide_Normalize_Denormals(cfType,Q,R,shift_length)
    sticky=(R~=0);

    if(shift_length>0)
        if(shift_length>1)
            sticky=sticky||(bitsll(Q,Q.WordLength-shift_length)~=0);
        end

        if(shift_length<Q.WordLength)
            Q(:)=bitsrl(Q,shift_length);
        else
            Q(:)=0;
        end
    end

    mant=bitsliceget(Q,cfType.MantissaLength+1,1);
end

function[mant,sticky]=rdivide_Normalize_Normals(cfType,Q,R,shift_length)
    sticky=(R~=0);

    if(shift_length>0)
        if(shift_length>1)
            sticky=sticky||(bitsll(Q,Q.WordLength-shift_length)~=0);
        end

        if(shift_length==1)
            Q(:)=bitsrl(Q,1);
        elseif(shift_length>1)
            Q(:)=0;
        end
    end

    mant=bitsliceget(Q,cfType.MantissaLength+1,1);
end



function[exp_c,shift_length]=rdivide_Extract_Exp(cfType,exp_a_norm,exp_b_norm,denormal)
    if(denormal)
        [exp_c,shift_length]=rdivide_Extract_Exp_Denormals(cfType,exp_a_norm,exp_b_norm);
    else
        [exp_c,shift_length]=rdivide_Extract_Exp_Normals(cfType,exp_a_norm,exp_b_norm);
    end
end

function[exp_c,shift_length]=rdivide_Extract_Exp_Denormals(cfType,exp_a_norm,exp_b_norm)
    exp_tmp=fi(exp_a_norm-exp_b_norm+cast(cfType.ExponentBias,'like',exp_a_norm),1,exp_a_norm.WordLength,0);

    if(exp_tmp>=2*cfType.ExponentBias+1)

        shift_length=uint8(cfType.MantissaLength+2);
        exp_c=cfType.Exponent_Inf_or_NaN;
    elseif(exp_tmp<1)

        exp_c=fi(0,0,cfType.ExponentLength,0);

        if(exp_tmp>-(cfType.MantissaLength+1))
            shift_length=uint8(1-int8(exp_tmp));
        else
            shift_length=uint8(cfType.MantissaLength+2);
        end
    else

        shift_length=uint8(0);
        exp_c=fi(exp_tmp,0,cfType.ExponentLength,0);
    end
end

function[exp_c,shift_length]=rdivide_Extract_Exp_Normals(cfType,exp_a_norm,exp_b_norm)
    exp_tmp=fi(exp_a_norm-exp_b_norm+cast(cfType.ExponentBias,'like',exp_a_norm),1,exp_a_norm.WordLength,0);

    if(exp_tmp>=2*cfType.ExponentBias+1)

        shift_length=uint8(cfType.MantissaLength+2);
        exp_c=cfType.Exponent_Inf_or_NaN;
    elseif(exp_tmp<1)

        exp_c=fi(0,0,cfType.ExponentLength,0);

        if(exp_tmp==0)
            shift_length=uint8(1);
        else
            shift_length=uint8(cfType.MantissaLength+2);
        end
    else

        shift_length=uint8(0);
        exp_c=fi(exp_tmp,0,cfType.ExponentLength,0);
    end
end


function[Q,R]=rdivide_Long_Div(mant_a_norm,mant_b_norm,ML)
    Q=fi(0,0,ML+2,0);

    R=mant_a_norm;

    for ii=coder.unroll((ML+2):-1:1)
        [Q,R]=rdivide_Long_Div_get_digit(Q,R,mant_b_norm,ii);
    end
end

function[Q,R]=rdivide_Long_Div_get_digit(Q,R,mant_b_norm,ii)
    tmp=cast(R-mant_b_norm,'like',R);
    if(tmp>=0)
        Q(:)=bitset(Q,ii,1);
        R=tmp;
    end
    R(:)=bitsll(R,1);
end


function[exp_a_norm,mant_a_norm,exp_b_norm,mant_b_norm]=rdivide_Normalize_Exp_Mant(cfType,exp_a,mant_a,exp_b,mant_b,denormal)
    if(denormal)
        [exp_a_norm,mant_a_norm,exp_b_norm,mant_b_norm]=rdivide_Normalize_Exp_Mant_Denormals(cfType,exp_a,mant_a,exp_b,mant_b);
    else
        [exp_a_norm,mant_a_norm,exp_b_norm,mant_b_norm]=rdivide_Normalize_Exp_Mant_Normals(cfType,exp_a,mant_a,exp_b,mant_b);
    end
end

function[exp_a_norm,mant_a_norm,exp_b_norm,mant_b_norm]=rdivide_Normalize_Exp_Mant_Denormals(cfType,exp_a,mant_a,exp_b,mant_b)



    if(bitget(mant_a,mant_a.WordLength)==0)
        ia=int8(mant_a.WordLength)-int8(coder.customfloat.helpers.findFirst1(mant_a));
        exp_a_norm=fi(1-ia,1,cfType.ExponentLength+2,0);
        mant_a_norm=reinterpretcast(bitconcat(fi(0,0,2,0),bitsll(mant_a,ia)),numerictype(1,cfType.MantissaLength+3,0));
    else
        exp_a_norm=fi(exp_a,1,cfType.ExponentLength+2,0);
        mant_a_norm=reinterpretcast(bitconcat(fi(0,0,2,0),mant_a),numerictype(1,cfType.MantissaLength+3,0));
    end

    if(bitget(mant_b,mant_b.WordLength)==0)
        ib=int8(mant_b.WordLength)-int8(coder.customfloat.helpers.findFirst1(mant_b));
        exp_b_norm=fi(1-ib,1,cfType.ExponentLength+2,0);
        mant_b_norm=reinterpretcast(bitconcat(fi(0,0,2,0),bitsll(mant_b,ib)),numerictype(1,cfType.MantissaLength+3,0));
    else
        exp_b_norm=fi(exp_b,1,cfType.ExponentLength+2,0);
        mant_b_norm=reinterpretcast(bitconcat(fi(0,0,2,0),mant_b),numerictype(1,cfType.MantissaLength+3,0));
    end

    if(mant_a_norm<mant_b_norm)
        exp_a_norm(:)=exp_a_norm-cast(1,'like',exp_a_norm);
        mant_a_norm(:)=bitsll(mant_a_norm,1);
    end
end

function[exp_a_norm,mant_a_norm,exp_b_norm,mant_b_norm]=rdivide_Normalize_Exp_Mant_Normals(cfType,exp_a,mant_a,exp_b,mant_b)




    exp_a_norm=fi(exp_a,1,cfType.ExponentLength+2,0);
    mant_a_norm=reinterpretcast(bitconcat(fi(0,0,2,0),mant_a),numerictype(1,cfType.MantissaLength+3,0));

    exp_b_norm=fi(exp_b,1,cfType.ExponentLength+2,0);
    mant_b_norm=reinterpretcast(bitconcat(fi(0,0,2,0),mant_b),numerictype(1,cfType.MantissaLength+3,0));

    if(mant_a_norm<mant_b_norm)
        exp_a_norm(:)=exp_a_norm-cast(1,'like',exp_a_norm);
        mant_a_norm(:)=bitsll(mant_a_norm,1);
    end
end


function[exp,mant]=rdivide_Inf_or_NaN(cfType,exp_a,mant_a,exp_b,mant_b)
    if(exp_a==cfType.Exponent_Inf_or_NaN)

        exp=exp_a;
        mant=mant_a;

        if(exp_b==cfType.Exponent_Inf_or_NaN)

            mant=cfType.Mantissa_NaN;
        end
    else
        if(mant_b==0)

            exp=cast(0,'like',exp_a);
            mant=cast(0,'like',mant_a);
        else

            exp=exp_b;
            mant=mant_b;
        end
    end
end

