%#codegen








function[Sign,Exponent,Mantissa]=rsqrt(cfType,aSign,aExponent,aMantissa,denormal)
    coder.allowpcode('plain');

    [aExponent,aMantissa]=coder.customfloat.helpers.checkDenormal(cfType,aExponent,aMantissa,denormal);

    [setException,Sign,Exponent,Mantissa]=rsqrt_Inf_Or_NaN(cfType,aSign,aExponent,aMantissa);

    if(~setException)
        [exp_cor,mant_cor]=coder.customfloat.helpers.appendMantissaAndCorrectExponent(cfType,aExponent,aMantissa);
        [Exponent,Mantissa]=rsqrt_Main(cfType,exp_cor,mant_cor,denormal);
    end
end


function[Exponent,Mantissa]=rsqrt_Main(cfType,exp_cor,mant_cor,denormal)
    [exp_out,mant_norm]=rsqrt_Normalize(cfType,exp_cor,mant_cor,denormal);

    [V,W,Q,mX,m2X,m3X]=rsqrt_Prep(cfType,mant_norm);

    [mant_out,sticky]=rsqrt_Main_Iterations(cfType,V,W,Q,mX,m2X,m3X);



    [Exponent,Mantissa]=coder.customfloat.helpers.rounding(exp_out,mant_out,sticky);
end




function[V,W,Q,mX,m2X,m3X]=rsqrt_Iteration(V,W,Q,ii,mX,m2X,m3X)
    V(:)=bitsll(V,2);

    tmp1=cast(V+mX,'like',V);
    tmp2=cast(V+m2X,'like',V);
    tmp3=cast(V+m3X,'like',V);

    if(bitget(tmp3,tmp3.WordLength)==0)

        cn=fi(3,0,2,0);
        V(:)=tmp3;
    elseif(bitget(tmp2,tmp2.WordLength)==0)

        cn=fi(2,0,2,0);
        V(:)=tmp2;
    elseif(bitget(tmp1,tmp1.WordLength)==0)

        cn=fi(1,0,2,0);
        V(:)=tmp1;
    else

        cn=fi(0,0,2,0);
    end



    tmp4=bitsrl(cast(cn,'like',W),ii);
    W(:)=bitsll(W,1)+tmp4;



    tmp5=bitsll(Q,1);
    tmp6=bitset(tmp5,Q.FractionLength-ii+1,1);
    tmp7=cast(W-tmp6,'like',W);

    if(bitget(tmp7,tmp7.WordLength)==0)

        Q(:)=bitset(Q,Q.FractionLength-ii+1,1);
        W(:)=tmp7;
    end
end


function[mant_out,sticky]=rsqrt_Main_Iterations(cfType,V,W,Q,mX,m2X,m3X)
    for ii=coder.unroll(1:1:(cfType.MantissaLength+1))
        [V,W,Q,mX,m2X,m3X]=rsqrt_Iteration(V,W,Q,ii,mX,m2X,m3X);
    end

    sticky=((V~=0)&&(W~=0));
    mant_out=bitsliceget(Q,Q.FractionLength,Q.FractionLength-cfType.MantissaLength);
end










function[V,W,Q,mX,m2X,m3X]=rsqrt_Prep(cfType,mant_norm)
    FullLength=cfType.MantissaLength+6;
    FracLength=cfType.MantissaLength+2;
    Q=fi(1,1,FullLength,FracLength);

    X=reinterpretcast(bitconcat(fi(0,0,FullLength-mant_norm.WordLength,0),mant_norm),...
    numerictype(1,FullLength,FracLength));
    tmp1=bitsll(X,1);
    tmp2=cast(X+tmp1,'like',X);

    mX=cast(-X,'like',X);
    m2X=cast(-tmp1,'like',X);
    m3X=cast(-tmp2,'like',X);

    if(tmp1>1)

        V=cast(cast(1,'like',X)-X,'like',X);
        W=cast(0,'like',X);
    elseif(tmp2>1)

        V=cast(cast(1,'like',X)-tmp1,'like',X);
        W=cast(1,'like',X);
    else

        V=cast(cast(1,'like',X)-tmp2,'like',X);
        W=cast(2,'like',X);
    end
end


function[exp_out,mant_out]=rsqrt_Normalize(cfType,exp_cor,mant_cor,denormal)
    if(denormal)
        [exp_out,mant_out]=rsqrt_Normalize_Denormals(cfType,exp_cor,mant_cor);
    else
        [exp_out,mant_out]=rsqrt_Normalize_Normals(cfType,exp_cor,mant_cor);
    end
end

function[exp_out,mant_norm]=rsqrt_Normalize_Denormals(cfType,exp_cor,mant_cor)










    pos=coder.customfloat.helpers.findFirst1(mant_cor);
    shift_length=uint8(mant_cor.WordLength)-pos;

    mant_tmp=bitsll(mant_cor,shift_length);
    mant_norm=reinterpretcast(bitconcat(mant_tmp,fi(0,0,2,0)),...
    numerictype(0,cfType.MantissaLength+3,cfType.MantissaLength+2));

    tmp1=reinterpretcast(bitconcat(fi(0,0,1,0),exp_cor),...
    numerictype(1,cfType.ExponentLength+1,0));
    exp_norm=fi(tmp1-shift_length,1,cfType.ExponentLength+1,0);

    if(bitget(exp_norm,1)==1)

        if(mant_norm~=1)
            mant_norm(:)=bitsrl(mant_norm,2);
            exp_tmp=fi(3*cfType.ExponentBias-2,0,cfType.ExponentLength+1,0);
        else
            exp_tmp=fi(3*cfType.ExponentBias,0,cfType.ExponentLength+1,0);
        end
    else

        mant_norm(:)=bitsrl(mant_norm,1);
        exp_tmp=fi(3*cfType.ExponentBias-1,0,cfType.ExponentLength+1,0);
    end

    tmp2=fi(exp_tmp-exp_norm,0,cfType.ExponentLength+1,0);

    exp_out=bitsliceget(tmp2,cfType.ExponentLength+1,2);
end

function[exp_out,mant_norm]=rsqrt_Normalize_Normals(cfType,exp_cor,mant_cor)










    mant_norm=reinterpretcast(bitconcat(mant_cor,fi(0,0,2,0)),...
    numerictype(0,cfType.MantissaLength+3,cfType.MantissaLength+2));

    exp_norm=bitconcat(fi(0,0,1,0),exp_cor);

    if(bitget(exp_norm,1)==1)

        if(mant_norm~=1)
            mant_norm(:)=bitsrl(mant_norm,2);
            exp_tmp=fi(3*cfType.ExponentBias-2,0,cfType.ExponentLength+1,0);
        else
            exp_tmp=fi(3*cfType.ExponentBias,0,cfType.ExponentLength+1,0);
        end
    else

        mant_norm(:)=bitsrl(mant_norm,1);
        exp_tmp=fi(3*cfType.ExponentBias-1,0,cfType.ExponentLength+1,0);
    end

    tmp2=fi(exp_tmp-exp_norm,0,cfType.ExponentLength+1,0);

    exp_out=bitsliceget(tmp2,cfType.ExponentLength+1,2);
end


function[setException,Sign,Exponent,Mantissa]=rsqrt_Inf_Or_NaN(cfType,aSign,aExponent,aMantissa)
    setException=false;
    Sign=aSign;
    Exponent=aExponent;
    Mantissa=aMantissa;

    if(aExponent==cfType.Exponent_Inf_or_NaN)
        setException=true;

        if(aMantissa==0)
            if(aSign==1)

                Mantissa=cfType.Mantissa_NaN;
            else

                Exponent=fi(0,0,cfType.ExponentLength,0);
            end

        end
    elseif(aExponent==0)&&(aMantissa==0)

        setException=true;

        Sign=fi(0,0,1,0);
        Exponent=cfType.Exponent_Inf_or_NaN;
    elseif(aSign==1)

        setException=true;
        Exponent=cfType.Exponent_Inf_or_NaN;
        Mantissa=cfType.Mantissa_NaN;
    end
end