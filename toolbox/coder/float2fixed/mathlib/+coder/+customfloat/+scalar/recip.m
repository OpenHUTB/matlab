%#codegen






function[Sign,Exponent,Mantissa]=recip(cfType,aSign,aExponent,aMantissa,denormal)
    coder.allowpcode('plain');

    [aExponent,aMantissa]=coder.customfloat.helpers.checkDenormal(cfType,aExponent,aMantissa,denormal);


    Sign=aSign;


    if(aExponent==cfType.Exponent_Inf_or_NaN)||((aExponent==0)&&(aMantissa==0))
        [Exponent,Mantissa]=recip_Inf_or_NaN(cfType,aExponent,aMantissa);
    else
        [exp_a_cor,mant_a_cor]=coder.customfloat.helpers.appendMantissaAndCorrectExponent(cfType,aExponent,aMantissa);
        [Exponent,Mantissa]=recip_Normal_Long_Div(cfType,exp_a_cor,mant_a_cor,denormal);
    end

end


function[exp,mant]=recip_Normal_Long_Div(cfType,exp_a,mant_a,denormal)


    [exp_a_norm,mant_a_norm]=recip_Normalize_Exp_Mant(cfType,exp_a,mant_a,denormal);


    [mant_1_norm,shifted]=recip_Get_Divident(cfType,mant_a_norm);






    [exp_c,shift_length]=recip_Extract_Exp(cfType,exp_a_norm,shifted,denormal);





    [Q,R]=recip_Long_Div(mant_1_norm,mant_a_norm,cfType.MantissaLength);


    [mant_norm,sticky]=recip_Normalize(cfType,Q,R,shift_length,denormal);


    if(denormal)
        [exp,mant]=coder.customfloat.helpers.rounding(exp_c,mant_norm,sticky);
    else
        [exp,mant]=coder.customfloat.helpers.rounding_normals(exp_c,mant_norm,sticky);
    end

end


function[mant,sticky]=recip_Normalize(cfType,Q,R,shift_length,denormal)
    if(denormal)
        [mant,sticky]=recip_Normalize_Denormals(cfType,Q,R,shift_length);
    else
        [mant,sticky]=recip_Normalize_Normals(cfType,Q,R,shift_length);
    end
end

function[mant,sticky]=recip_Normalize_Denormals(cfType,Q,R,shift_length)
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

function[mant,sticky]=recip_Normalize_Normals(cfType,Q,R,shift_length)
    sticky=(R~=0);

    if(shift_length>0)
        if(shift_length==1)
            sticky=sticky||(bitget(Q,1)~=0);
        else
            sticky=sticky||(bitsll(Q,1)~=0);
        end

        if(shift_length==1)
            Q(:)=bitsrl(Q,1);
        elseif(shift_length>1)
            Q(:)=0;
        end
    end

    mant=bitsliceget(Q,cfType.MantissaLength+1,1);
end




function[exp_c,shift_length]=recip_Extract_Exp(cfType,exp_a_norm,shifted,denormal)
    if(denormal)
        [exp_c,shift_length]=recip_Extract_Exp_Denormals(cfType,exp_a_norm,shifted);
    else
        [exp_c,shift_length]=recip_Extract_Exp_Normals(cfType,exp_a_norm,shifted);
    end
end

function[exp_c,shift_length]=recip_Extract_Exp_Denormals(cfType,exp_a_norm,shifted)
    if(shifted)
        exp_tmp=fi(cast(2*cfType.ExponentBias-1,'like',exp_a_norm)-exp_a_norm,1,exp_a_norm.WordLength,0);
    else
        exp_tmp=fi(cast(2*cfType.ExponentBias,'like',exp_a_norm)-exp_a_norm,1,exp_a_norm.WordLength,0);
    end

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

function[exp_c,shift_length]=recip_Extract_Exp_Normals(cfType,exp_a_norm,shifted)
    if(shifted)
        exp_tmp=fi(cast(2*cfType.ExponentBias-1,'like',exp_a_norm)-exp_a_norm,1,exp_a_norm.WordLength,0);
    else
        exp_tmp=fi(cast(2*cfType.ExponentBias,'like',exp_a_norm)-exp_a_norm,1,exp_a_norm.WordLength,0);
    end

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


function[Q,R]=recip_Long_Div(mant_a_norm,mant_b_norm,ML)
    Q=fi(0,0,ML+2,0);

    R=mant_a_norm;

    for ii=coder.unroll((ML+2):-1:1)
        [Q,R]=recip_Long_Div_get_digit(Q,R,mant_b_norm,ii);
    end
end

function[Q,R]=recip_Long_Div_get_digit(Q,R,mant_b_norm,ii)
    tmp=cast(R-mant_b_norm,'like',R);
    if(tmp>=0)
        Q(:)=bitset(Q,ii,1);
        R=tmp;
    end
    R(:)=bitsll(R,1);
end


function[mant_1_norm,shifted]=recip_Get_Divident(cfType,mant_a)
    mant_1_norm=fi(0,1,cfType.MantissaLength+3,0);

    if(bitsliceget(mant_a,cfType.MantissaLength,1)~=0)
        shifted=true;
        mant_1_norm(:)=bitset(mant_1_norm,cfType.MantissaLength+2);
    else
        shifted=false;
        mant_1_norm(:)=bitset(mant_1_norm,cfType.MantissaLength+1);
    end
end


function[exp_a_norm,mant_a_norm]=recip_Normalize_Exp_Mant(cfType,exp_a,mant_a,denormal)
    if(denormal)
        [exp_a_norm,mant_a_norm]=recip_Normalize_Exp_Mant_Denormals(cfType,exp_a,mant_a);
    else
        [exp_a_norm,mant_a_norm]=recip_Normalize_Exp_Mant_Normals(cfType,exp_a,mant_a);
    end
end

function[exp_a_norm,mant_a_norm]=recip_Normalize_Exp_Mant_Denormals(cfType,exp_a,mant_a)


    if(bitget(mant_a,mant_a.WordLength)==0)
        ia=int8(mant_a.WordLength)-int8(coder.customfloat.helpers.findFirst1(mant_a));
        exp_a_norm=fi(1-ia,1,cfType.ExponentLength+2,0);
        mant_a_norm=reinterpretcast(bitconcat(fi(0,0,2,0),bitsll(mant_a,ia)),numerictype(1,cfType.MantissaLength+3,0));
    else
        exp_a_norm=fi(exp_a,1,cfType.ExponentLength+2,0);
        mant_a_norm=reinterpretcast(bitconcat(fi(0,0,2,0),mant_a),numerictype(1,cfType.MantissaLength+3,0));
    end
end

function[exp_a_norm,mant_a_norm]=recip_Normalize_Exp_Mant_Normals(cfType,exp_a,mant_a)


    exp_a_norm=fi(exp_a,1,cfType.ExponentLength+2,0);
    mant_a_norm=reinterpretcast(bitconcat(fi(0,0,2,0),mant_a),numerictype(1,cfType.MantissaLength+3,0));
end



function[exp,mant]=recip_Inf_or_NaN(cfType,exp_a,mant_a)
    if(exp_a==cfType.Exponent_Inf_or_NaN)
        mant=mant_a;
        if(mant_a==0)

            exp=fi(0,0,cfType.ExponentLength,0);
        else

            exp=exp_a;
        end
    else

        exp=cfType.Exponent_Inf_or_NaN;
        mant=fi(0,0,cfType.MantissaLength,0);
    end
end

