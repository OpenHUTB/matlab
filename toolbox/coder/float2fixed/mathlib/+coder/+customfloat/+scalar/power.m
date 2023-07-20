%#codegen












function[Sign,Exponent,Mantissa]=power(cfType,aSign,aExponent,aMantissa,bSign,bExponent,bMantissa,...
    denormal,Log2TableForLog2,Log2MinusTableForLog2,Log2E,...
    Log2TableForPow2,Log2MinusTableForPow2,Ln2)
    coder.allowpcode('plain');

    [aExponent,aMantissa]=coder.customfloat.helpers.checkDenormal(cfType,aExponent,aMantissa,denormal);
    [bExponent,bMantissa]=coder.customfloat.helpers.checkDenormal(cfType,bExponent,bMantissa,denormal);

    [bIsInt,bIsOdd,bIsZero]=pow_Check_Exponent(cfType,bExponent,bMantissa);
    [aIsZero,aIsOne]=pow_Check_Base(cfType,aExponent,aMantissa);

    if((aExponent==cfType.Exponent_Inf_or_NaN)||(bExponent==cfType.Exponent_Inf_or_NaN)||...
        aIsZero||aIsOne||bIsZero||(aSign&&(~bIsInt)))
        [Sign,Exponent,Mantissa]=pow_Inf_or_NaN(cfType,aSign,aExponent,aMantissa,bSign,bExponent,bMantissa,...
        aIsZero,aIsOne,bIsInt,bIsOdd,bIsZero);
    else
        [exp_a_cor,mant_a_cor]=coder.customfloat.helpers.appendMantissaAndCorrectExponent(cfType,aExponent,aMantissa);
        [exp_b_cor,mant_b_cor]=coder.customfloat.helpers.appendMantissaAndCorrectExponent(cfType,bExponent,bMantissa);

        [Sign,Exponent,Mantissa]=pow_Main(cfType,exp_a_cor,mant_a_cor,bSign,exp_b_cor,mant_b_cor,...
        denormal,Log2TableForLog2,Log2MinusTableForLog2,Log2E,...
        Log2TableForPow2,Log2MinusTableForPow2,Ln2);
        if(aSign&&bIsOdd)
            Sign=fi(1,0,1,0);
        end
    end
end

function[Sign,Exponent,Mantissa]=pow_Main(cfType,exp_a_cor,mant_a_cor,bSign,exp_b_cor,mant_b_cor,...
    denormal,Log2TableForLog2,Log2MinusTableForLog2,Log2E,...
    Log2TableForPow2,Log2MinusTableForPow2,Ln2)

    [exp_a_norm,mant_a_norm]=pow_Normalize_Exp_Mant(cfType,exp_a_cor,mant_a_cor,denormal,cfType.ExponentLength+1);
    [exp_b_norm,mant_b_norm]=pow_Normalize_Exp_Mant(cfType,exp_b_cor,mant_b_cor,denormal,1);






    [L,w,exp_unbiased,~]=log2_Prep(cfType,exp_a_norm,mant_a_norm,Log2TableForLog2);


    [L,w]=log2_First_Iteration(L,w,Log2MinusTableForLog2);
    [L,w]=log2_Second_Iteration(L,w,Log2TableForLog2,Log2MinusTableForLog2);




    [L,w]=log2_Main_Iterations(cfType,L,w,Log2TableForLog2,Log2MinusTableForLog2);


    L_out=log2_Final_Approximation(cfType,L,w,Log2E);


    Sum=log2_Add_Exp_And_Fractional_Part(cfType,exp_unbiased,L_out);


    [sign_log2_a,exp_log2x_out,mant_log2x_out]=log2_Normalize_Sum(cfType,Sum);


    sign_prod=bitxor(sign_log2_a,bSign);
    mant_prod=mant_b_norm*mant_log2x_out;
    exp_sum=cast(exp_log2x_out+exp_b_norm,'like',exp_log2x_out);

    [exp_sum,mant_cor]=pow_Normalize_Prod(cfType,exp_sum,mant_prod);


    Sign=fi(0,0,1,0);

    [in_range,mant_ext]=pow2_Check_Exp_Range_and_Shift_Mant(cfType,sign_prod,exp_sum,mant_cor,denormal);

    if(in_range)
        [exp_out,mant_frac,sticky]=pow2_Extract_Exp_Mant(cfType,sign_prod,mant_ext);


        [y,w]=pow2_First_Iteration(mant_frac,Log2TableForPow2);


        [y,w]=pow2_Main_Iterations(cfType,y,w,Log2TableForPow2,Log2MinusTableForPow2);


        y=pow2_Final_Approximation(cfType,y,w,Ln2);


        [exp_norm,mant_out]=pow2_Normalize_Answer(cfType,exp_out,y,denormal);


        if(denormal)
            [Exponent,Mantissa]=coder.customfloat.helpers.rounding(exp_norm,mant_out,sticky);
        else
            [Exponent,Mantissa]=coder.customfloat.helpers.rounding_normals(exp_norm,mant_out,sticky);
        end
    else
        Mantissa=fi(0,0,cfType.MantissaLength,0);

        if(sign_prod)
            Exponent=fi(0,0,cfType.ExponentLength,0);
        else
            Exponent=cfType.Exponent_Inf_or_NaN;
        end
    end
end



function[exp_norm,mant_out]=pow2_Normalize_Answer(cfType,exp_out,y,denormal)
    if(denormal)
        [exp_norm,mant_out]=pow2_Normalize_Answer_Denormals(cfType,exp_out,y);
    else
        [exp_norm,mant_out]=pow2_Normalize_Answer_Normals(cfType,exp_out,y);
    end
end

function[exp_norm,mant_out]=pow2_Normalize_Answer_Denormals(cfType,exp_out,y)
    if(exp_out<=0)
        shift_length=uint8(1-exp_out);
    else
        shift_length=uint8(0);
    end

    if(shift_length>=y.WordLength)
        y(:)=0;
    else
        y(:)=bitsrl(y,shift_length);
    end

    if bitget(y,y.FractionLength+2)
        exp_out(:)=exp_out+1;
    elseif(bitget(y,y.FractionLength+1)==0)
        exp_out(:)=0;
    end

    if(exp_out>cfType.Exponent_Inf_or_NaN)
        exp_norm=fi(cfType.Exponent_Inf_or_NaN,0,cfType.ExponentLength,0);
        mant_out=fi(0,0,cfType.MantissaLength+1,0);
    else
        exp_norm=fi(exp_out,0,cfType.ExponentLength,0);
        mant_out=bitsliceget(y,y.FractionLength,y.FractionLength-cfType.MantissaLength);
    end
end

function[exp_norm,mant_out]=pow2_Normalize_Answer_Normals(cfType,exp_out,y)
    if(exp_out>0)
        exp_norm=fi(exp_out,0,cfType.ExponentLength,0);
        mant_out=bitsliceget(y,cfType.PowIntermediatePow2Prec,cfType.PowIntermediatePow2Prec-cfType.MantissaLength);
    else
        mant_out=fi(0,0,cfType.MantissaLength+1,0);
        if(bitget(y,cfType.PowIntermediatePow2Prec)&&(bitget(exp_out,exp_out.WordLength)==0))
            exp_norm=fi(1,0,cfType.ExponentLength,0);
        else
            exp_norm=fi(0,0,cfType.ExponentLength,0);
        end
    end
end


function y=pow2_Final_Approximation(cfType,y,w,Ln2)
    tmp1=reinterpretcast(bitsliceget(w,w.WordLength,cfType.PowNumberOfPow2Iterations+1),...
    numerictype(1,w.WordLength-cfType.PowNumberOfPow2Iterations,w.WordLength-cfType.PowNumberOfPow2Iterations-2));
    tmp2=cast(Ln2,'like',tmp1);
    tmp3=cast(tmp1*tmp2,'like',tmp1);
    tmp4=reinterpretcast(bitsliceget(y,y.WordLength-1,y.WordLength-tmp1.WordLength),...
    numerictype(1,tmp1.WordLength,tmp1.FractionLength));
    tmp5=cast(tmp3*tmp4,'like',y);
    tmp6=bitsra(tmp5,cfType.PowNumberOfPow2Iterations);
    y(:)=y+tmp6;






end


function[y,w]=pow2_Main_Iterations(cfType,y,w,Log2Table,Log2MinusTable)

    for ii=coder.unroll(2:1:cfType.PowNumberOfPow2Iterations)
        [y,w]=pow2_Iteration(y,w,ii,Log2Table,Log2MinusTable);
    end
end

function[y,w]=pow2_Iteration(y,w,ii,Log2Table,Log2MinusTable)
    w(:)=bitsll(w,1);
    tmp1=cast(bitsrl(y,ii),'like',y);

    if(bitget(w,w.WordLength)==1)&&(bitget(w,w.WordLength-1)==0)
        w(:)=w+Log2MinusTable(ii);
        y(:)=y-tmp1;
    elseif(bitget(w,w.WordLength)==0)&&(bitget(w,w.WordLength-1)==1)
        w(:)=w-Log2Table(ii);
        y(:)=y+tmp1;
    end
end


function[y,w]=pow2_First_Iteration(mant_frac,Log2Table)
    w=cast(bitsll(mant_frac,1),'like',mant_frac);

    if bitget(w,w.WordLength-1)
        w(:)=w-Log2Table(1);
        y=cast(1.5,'like',Log2Table(1));
    else
        y=cast(1,'like',Log2Table(1));
    end
end






function[exp_out,mant_frac,sticky]=pow2_Extract_Exp_Mant(cfType,aSign,mant_ext)
    mant_frac=reinterpretcast(bitconcat(fi(0,0,2,0),bitsliceget(mant_ext,cfType.PowIntermediatePow2Prec,1)),...
    numerictype(1,cfType.PowIntermediatePow2Prec+2,cfType.PowIntermediatePow2Prec));

    mant_tmp=cast(cast(1,'like',mant_frac)-mant_frac,'like',mant_frac);

    sticky=(bitget(mant_tmp,mant_tmp.WordLength-1)==0);

    exp_tmp=reinterpretcast(bitconcat(fi(0,0,1,0),bitsliceget(mant_ext,mant_ext.WordLength,cfType.PowIntermediatePow2Prec+1)),...
    numerictype(1,cfType.ExponentLength+2,0));
    exp_adj=fi(cfType.ExponentBias,1,cfType.ExponentLength+2,0);

    if(aSign)
        if(sticky)
            mant_frac(:)=mant_tmp;
            exp_adj=fi(cfType.ExponentBias-1,1,cfType.ExponentLength+2,0);
        end

        exp_out=cast(exp_adj-exp_tmp,'like',exp_tmp);
    else
        exp_out=cast(exp_adj+exp_tmp,'like',exp_tmp);
    end
end


function[in_range,mant_ext]=pow2_Check_Exp_Range_and_Shift_Mant(cfType,aSign,exp_cor,mant_cor,denormal)
    if bitget(exp_cor,exp_cor.WordLength)
        exp_tmp=reinterpretcast(bitconcat(fi(2^(cfType.ExponentLength+3-exp_cor.WordLength)-1,0,cfType.ExponentLength+3-exp_cor.WordLength,0),exp_cor),numerictype(1,cfType.ExponentLength+3,0));
    else
        exp_tmp=reinterpretcast(bitconcat(fi(0,0,cfType.ExponentLength+3-exp_cor.WordLength,0),exp_cor),numerictype(1,cfType.ExponentLength+3,0));
    end

    if(aSign)
        if(denormal)
            upperBound=coder.const(int16(ceil(log2(double(cfType.ExponentBias+cfType.MantissaLength))))...
            +int16(cfType.ExponentBias));
        else
            upperBound=coder.const(int16(ceil(log2(double(cfType.ExponentBias))))+int16(cfType.ExponentBias));
        end
    else
        upperBound=coder.const(int16(ceil(log2(2^(double(cfType.ExponentLength))-...
        double(cfType.ExponentBias)-1)))+int16(cfType.ExponentBias));
    end

    if(exp_tmp>=upperBound)
        in_range=false;
        mant_ext=fi(0,0,cfType.ExponentLength+cfType.PowIntermediatePow2Prec+1,cfType.PowIntermediatePow2Prec);
    else
        in_range=true;

        exp_unbiased=cast(exp_tmp-cast(cfType.ExponentBias,'like',exp_tmp),'like',exp_tmp);

        shift_sign=bitget(exp_unbiased,exp_unbiased.WordLength);

        if(shift_sign)
            shift_length=cast(cast(cfType.ExponentBias,'like',exp_cor)-exp_cor,'like',exp_cor);

            tmp2=bitconcat(fi(0,0,cfType.ExponentLength,0),...
            coder.customfloat.helpers.safe_bitsra(mant_cor,shift_length));
        else
            shift_length=cast(exp_unbiased,'like',exp_cor);

            tmp1=bitconcat(fi(0,0,cfType.ExponentLength,0),mant_cor);
            tmp2=bitsll(tmp1,shift_length);
        end
        mant_ext=reinterpretcast(bitsliceget(tmp2,tmp2.WordLength,tmp2.WordLength-cfType.ExponentLength-cfType.PowIntermediatePow2Prec),...
        numerictype(0,cfType.ExponentLength+cfType.PowIntermediatePow2Prec+1,cfType.PowIntermediatePow2Prec));
    end
end


function[exp_sum,mant_cor]=pow_Normalize_Prod(~,exp_sum,mant_prod)
    if bitget(mant_prod,mant_prod.FractionLength+2)
        exp_sum(:)=exp_sum+cast(1,'like',exp_sum);
        mant_cor=bitsliceget(mant_prod,mant_prod.FractionLength+2,2);
    else
        mant_cor=bitsliceget(mant_prod,mant_prod.FractionLength+1,1);
    end

    mant_cor=reinterpretcast(mant_cor,numerictype(0,mant_cor.WordLength,mant_cor.WordLength-1));
end


function[Sign,exp_out,mant_out]=log2_Normalize_Sum(cfType,Sum)
    Sign=bitget(Sum,Sum.WordLength);
    FL=Sum.FractionLength;

    ML=cfType.WordLength+1;

    Sum=bitsliceget(abs(Sum),Sum.WordLength-1,1);

    pos=coder.customfloat.helpers.findFirst1(Sum);

    if(pos==0)
        exp_out=fi(-cfType.ExponentBias,1,cfType.ExponentLength+2,0);
        mant_out=fi(0,0,ML+1,ML);
    else
        exp_out=fi(-FL-1,1,cfType.ExponentLength+2,0);
        exp_out(:)=exp_out+cast(pos,'like',exp_out);
        tmp1=uint8(Sum.WordLength)-pos;
        Sum(:)=bitsll(Sum,tmp1);
        mant_out=reinterpretcast(bitsliceget(Sum,Sum.WordLength,Sum.WordLength-ML),...
        numerictype(0,ML+1,ML));
    end
end


function Sum=log2_Add_Exp_And_Fractional_Part(cfType,exp_unbiased,L)

    extrabits=max(2*(cfType.MantissaLength+5)+1-L.FractionLength,0);
    FractionLength=L.FractionLength+extrabits;
    FullLength=3+cfType.ExponentLength+FractionLength;
    exp_tmp=reinterpretcast(bitconcat(exp_unbiased,fi(0,0,FractionLength,0)),...
    numerictype(1,FullLength,FractionLength));
    if(extrabits>0)
        tmp1=reinterpretcast(bitconcat(L,fi(0,0,extrabits,0)),...
        numerictype(1,L.WordLength+extrabits,FractionLength));
    else
        tmp1=L;
    end

    if(bitget(tmp1,tmp1.WordLength)==0)
        tmp2=reinterpretcast(bitconcat(fi(0,0,cfType.ExponentLength,0),tmp1),...
        numerictype(1,FullLength,FractionLength));
    else
        tmp2=reinterpretcast(bitconcat(fi(-1,1,cfType.ExponentLength,0),tmp1),...
        numerictype(1,FullLength,FractionLength));
    end

    Sum=cast(exp_tmp-tmp2,'like',exp_tmp);
end


function L_out=log2_Final_Approximation(cfType,L,w,Log2E)
    extrabits=max(2*(cfType.WordLength+1)-L.FractionLength,0);
    FullLength=L.WordLength+extrabits;
    FracLength=L.FractionLength+extrabits;
    if(extrabits>0)
        L_out=reinterpretcast(bitconcat(L,fi(0,0,extrabits,0)),numerictype(1,FullLength,FracLength));
    else
        L_out=L;
    end

    if(w~=0)
        sign=bitget(w,w.WordLength);
        w_abs=w;
        if(sign==1)
            w_abs(:)=-w;
        end

        if(w_abs>=2)
            tmp=bitsra(w_abs,1);
            j=int8(-1);
        else
            pos=int8(coder.customfloat.helpers.findFirst1(w_abs));
            j=int8(w.FractionLength-pos+1);

            tmp=bitsll(w_abs,j);
        end

        tmp1=bitsra(w,cfType.PowNumberOfLog2Iterations+2);
        ONE=cast(1,'like',w);
        tmp2=cast(ONE-tmp1,'like',w);

        tmp_m1=reinterpretcast(bitsliceget(tmp,w.FractionLength+1,1),numerictype(0,w.FractionLength+1,w.FractionLength));
        tmp_m2=reinterpretcast(bitsliceget(tmp2,w.FractionLength+1,1),numerictype(0,w.FractionLength+1,w.FractionLength));

        tmp3=fi(tmp_m1*tmp_m2,0,w.FractionLength+4,w.FractionLength+2);
        appx=cast(tmp3*Log2E,'like',L);
        if(sign==1)
            appx(:)=-appx;
        end

        shift=cfType.PowNumberOfLog2Iterations+1+cast(j,'like',cfType.PowNumberOfLog2Iterations);
        tmp4=bitsra(appx,shift);
        L_out(:)=L_out-tmp4;
    end
end

function[L,w]=log2_Main_Iterations(cfType,L,w,Log2TableForLog2,Log2MinusTableForLog2)
    for ii=coder.unroll(3:1:cfType.PowNumberOfLog2Iterations)
        [L,w]=log2_Iteration(L,w,ii,Log2TableForLog2,Log2MinusTableForLog2);
    end
end

function[L,w]=log2_Iteration(L,w,ii,Log2TableForLog2,Log2MinusTableForLog2)
    w_hat=reinterpretcast(bitsliceget(w,w.WordLength,w.FractionLength-3),...
    numerictype(1,w.WordLength-w.FractionLength+4,4));

    tmp1=cast(bitsra(w,ii-1),'like',w);
    w(:)=bitsll(w,1);
    TWO=cast(2,'like',w);
    tmp2=cast(TWO+tmp1,'like',w);
    tmp3=cast(w-tmp2,'like',w);
    tmp4=cast(w+tmp2,'like',w);

    if(w_hat>0.5)

        w(:)=tmp3;
        L(:)=L-Log2MinusTableForLog2(ii);
    elseif(w_hat<-0.5)

        w(:)=tmp4;
        L(:)=L+Log2TableForLog2(ii);
    end
end



function[L,w,exp_unbiased,sticky]=log2_Prep(cfType,exp_norm,mant_norm,Log2TableForLog2)
    exp_unbiased=exp_norm;
    exp_unbiased(:)=exp_unbiased-cast(cfType.ExponentBias,'like',exp_norm);

    tmp=(bitsliceget(mant_norm,mant_norm.FractionLength,1)~=0);

    if(tmp)
        ONE=cast(1,'like',mant_norm);
        tmp1=cast(mant_norm-ONE,'like',mant_norm);
        tmp2=bitsll(tmp1,1);
        w=cast(tmp2,'like',mant_norm);
    else
        w=cast(0,'like',mant_norm);
    end

    L=cast(0,'like',Log2TableForLog2(1));
    sticky=tmp;
end

function[L,w]=log2_First_Iteration(L,w,Log2MinusTableForLog2)
    if(w>1)

        TWO=cast(2,'like',w);
        w(:)=w-TWO;
        L(:)=L-Log2MinusTableForLog2(1);
    else

        w(:)=bitsll(w,1);
    end
end

function[L,w]=log2_Second_Iteration(L,w,Log2TableForLog2,Log2MinusTableForLog2)
    tmp1=cast(bitsra(w,1),'like',w);
    w_hat=reinterpretcast(bitsliceget(w,w.WordLength,w.FractionLength-1),numerictype(1,w.WordLength-w.FractionLength+2,2));

    w(:)=bitsll(w,1);
    TWO=cast(2,'like',w);
    tmp2=cast(TWO+tmp1,'like',w);
    tmp3=cast(w-tmp2,'like',w);
    tmp4=cast(w+tmp2,'like',w);

    if(w_hat>=0.75)

        w(:)=tmp3;
        L(:)=L-Log2MinusTableForLog2(2);
    elseif(w_hat<-0.5)

        w(:)=tmp4;
        L(:)=L+Log2TableForLog2(2);
    end
end


function[exp_norm,mant_norm]=pow_Normalize_Exp_Mant_Normal(cfType,exp_a,mant_a,extrabits)
    exp_norm=fi(exp_a,1,cfType.ExponentLength+3,0);
    mant_norm=reinterpretcast(bitconcat(fi(0,0,4,0),mant_a,fi(0,0,extrabits,0)),...
    numerictype(1,5+cfType.MantissaLength+extrabits,cfType.MantissaLength+extrabits));
end


function[exp_norm,mant_norm]=pow_Normalize_Exp_Mant_Denormal(cfType,exp_a,mant_a,extrabits)
    if(bitget(mant_a,mant_a.WordLength)==0)
        ia=int8(mant_a.WordLength)-int8(coder.customfloat.helpers.findFirst1(mant_a));
        exp_norm=fi(1-ia,1,cfType.ExponentLength+3,0);
        mant_a(:)=bitsll(mant_a,ia);
    else
        exp_norm=fi(exp_a,1,cfType.ExponentLength+3,0);
    end

    mant_norm=reinterpretcast(bitconcat(fi(0,0,4,0),mant_a,fi(0,0,extrabits,0)),...
    numerictype(1,5+cfType.MantissaLength+extrabits,cfType.MantissaLength+extrabits));
end


function[exp_norm,mant_norm]=pow_Normalize_Exp_Mant(cfType,exp_cor,mant_cor,denormal,extrabits)
    if(denormal)
        [exp_norm,mant_norm]=pow_Normalize_Exp_Mant_Denormal(cfType,exp_cor,mant_cor,extrabits);
    else
        [exp_norm,mant_norm]=pow_Normalize_Exp_Mant_Normal(cfType,exp_cor,mant_cor,extrabits);
    end
end

function[Sign,Exponent,Mantissa]=pow_Inf_or_NaN(cfType,aSign,aExponent,aMantissa,bSign,bExponent,bMantissa,...
    aIsZero,aIsOne,bIsInt,bIsOdd,bIsZero)
    if((aExponent==cfType.Exponent_Inf_or_NaN)&&(aMantissa~=0))

        Sign=aSign;
        Exponent=aExponent;
        Mantissa=aMantissa;
    elseif((bExponent==cfType.Exponent_Inf_or_NaN)&&(bMantissa~=0))

        Sign=bSign;
        Exponent=bExponent;
        Mantissa=bMantissa;
    elseif bIsZero

        Sign=fi(0,0,1,0);
        Exponent=fi(cfType.ExponentBias,0,cfType.ExponentLength,0);
        Mantissa=fi(0,0,cfType.MantissaLength,0);
    elseif aIsZero
        Mantissa=fi(0,0,cfType.MantissaLength,0);



        Sign=fi(bIsInt&&bIsOdd&&aSign,0,1,0);

        if bSign

            Exponent=cfType.Exponent_Inf_or_NaN;
        else

            Exponent=fi(0,0,cfType.ExponentLength,0);
        end
    elseif aIsOne
        if aSign

            if bIsInt
                Sign=fi(bIsOdd,0,1,0);
                Exponent=fi(cfType.ExponentBias,0,cfType.ExponentLength,0);
                Mantissa=fi(0,0,cfType.MantissaLength,0);
            else

                Sign=aSign;
                Exponent=cfType.Exponent_Inf_or_NaN;
                Mantissa=cfType.Mantissa_NaN;
            end
        else

            Sign=fi(0,0,1,0);
            Exponent=fi(cfType.ExponentBias,0,cfType.ExponentLength,0);
            Mantissa=fi(0,0,cfType.MantissaLength,0);
        end
    elseif(aSign&&~(bIsInt))

        Sign=aSign;
        Exponent=cfType.Exponent_Inf_or_NaN;
        Mantissa=cfType.Mantissa_NaN;
    elseif(aExponent==cfType.Exponent_Inf_or_NaN)

        Sign=fi(bIsInt&&bIsOdd&&aSign,0,1,0);
        Mantissa=fi(0,0,cfType.MantissaLength,0);

        if bSign
            Exponent=fi(0,0,cfType.ExponentLength,0);
        else
            Exponent=cfType.Exponent_Inf_or_NaN;
        end
    else

        Sign=fi(0,0,1,0);
        Mantissa=fi(0,0,cfType.MantissaLength,0);

        if(xor(aExponent>=cfType.ExponentBias,bSign))

            Exponent=fi(cfType.Exponent_Inf_or_NaN,0,cfType.ExponentLength,0);
        else
            Exponent=fi(0,0,cfType.ExponentLength,0);
        end
    end
end

function[aIsZero,aIsOne]=pow_Check_Base(cfType,aExponent,aMantissa)
    aIsZero=(aExponent==0)&&(aMantissa==0);
    aIsOne=(aExponent==cfType.ExponentBias)&&(aMantissa==0);
end

function[bIsInt,bIsOdd,bIsZero]=pow_Check_Exponent(cfType,bExponent,bMantissa)
    pos=fi(bMantissa.WordLength+1-coder.customfloat.helpers.findLast1(bMantissa),1,cfType.ExponentLength+2,0);
    if(pos==bMantissa.WordLength+1)
        pos(:)=0;
    end
    tmp=cast(cast(bExponent,'like',pos)-cast(cfType.ExponentBias,'like',pos)-pos,'like',pos);
    bIsZero=(bExponent==0)&&(bMantissa==0);

    if bitget(tmp,tmp.WordLength)

        bIsInt=false;
        bIsOdd=false;
    else
        bIsInt=true;
        bIsOdd=(tmp==0);
    end
end
