%#codegen









function[Sign,Exponent,Mantissa]=log(cfType,aSign,aExponent,aMantissa,denormal,...
    LogTable,LogMinusTable,LogExpTable)
    coder.allowpcode('plain');

    [aExponent,aMantissa]=coder.customfloat.helpers.checkDenormal(cfType,aExponent,aMantissa,denormal);

    if(aExponent==cfType.Exponent_Inf_or_NaN)||(aSign==1)||...
        ((aExponent==0)&&(aMantissa==0))
        [Sign,Exponent,Mantissa]=log_Inf_or_NaN(cfType,aSign,aExponent,aMantissa);
    else
        [exp_cor,mant_cor]=coder.customfloat.helpers.appendMantissaAndCorrectExponent(cfType,aExponent,aMantissa);
        [Sign,Exponent,Mantissa]=log_Main(cfType,exp_cor,mant_cor,denormal,...
        LogTable,LogMinusTable,LogExpTable);
    end
end

function[Sign,Exponent,Mantissa]=log_Main(cfType,exp_cor,mant_cor,denormal,...
    LogTable,LogMinusTable,LogExpTable)

    [exp_norm,mant_norm]=log_Normalize_Exp_Mant(cfType,exp_cor,mant_cor,denormal);






    [L,w,exp_idx,sticky]=log_Prep(cfType,exp_norm,mant_norm,LogTable);


    [L,w,exp_idx]=log_First_Iteration(L,w,exp_idx);
    [L,w]=log_Second_Iteration(L,w,LogTable,LogMinusTable);




    [L,w]=log_Main_Iterations(cfType,L,w,LogTable,LogMinusTable);


    L=log_Final_Approximation(cfType,L,w);


    exp_log=log_Extract_ExpLog(LogExpTable,exp_idx);


    Sum=log_Add_Exp_And_Fractional_Part(cfType,exp_log,L);


    [Sign,exp_out,mant_out]=log_Normalize_Sum(cfType,Sum);


    [Exponent,Mantissa]=coder.customfloat.helpers.rounding(exp_out,mant_out,sticky);
end


function[Sign,exp_out,mant_out]=log_Normalize_Sum(cfType,Sum)
    Sign=bitget(Sum,Sum.WordLength);
    FL=Sum.FractionLength;

    Sum=bitsliceget(abs(Sum),Sum.WordLength-1,1);

    pos=coder.customfloat.helpers.findFirst1(Sum);

    if(pos==0)
        exp_out=fi(0,0,cfType.ExponentLength,0);
        mant_out=fi(0,0,cfType.MantissaLength+1,0);
    else
        exp_out=fi(0,0,cfType.ExponentLength,0);
        tmp=fi(cfType.ExponentBias-FL-1,...
        1,cfType.ExponentLength+2,0);
        exp_out(:)=tmp+cast(pos,'like',tmp);
        tmp1=uint8(Sum.WordLength)-pos;
        Sum(:)=bitsll(Sum,tmp1);
        mant_out=bitsliceget(Sum,Sum.WordLength-1,Sum.WordLength-cfType.MantissaLength-1);
    end
end


function Sum=log_Add_Exp_And_Fractional_Part(cfType,exp_log,L)

    FractionLength=2*cfType.MantissaLength+1;
    FullLength=3+cfType.ExponentLength+FractionLength;
    if(bitget(L,L.WordLength)==0)
        L=reinterpretcast(bitconcat(fi(0,0,cfType.ExponentLength,0),L),...
        numerictype(1,FullLength,FractionLength));
    else
        L=reinterpretcast(bitconcat(fi(-1,1,cfType.ExponentLength,0),L),...
        numerictype(1,FullLength,FractionLength));
    end

    Sum=cast(exp_log-L,'like',exp_log);
end


function exp_log=log_Extract_ExpLog(LogExpTable,exp_idx)
    exp_log=LogExpTable(exp_idx);
end


function L=log_Final_Approximation(cfType,L,w)
    extrabits=2*(cfType.MantissaLength)+1-L.FractionLength;
    FullLength=L.WordLength+extrabits;
    FracLength=L.FractionLength+extrabits;
    L=reinterpretcast(bitconcat(L,fi(0,0,extrabits,0)),numerictype(1,FullLength,FracLength));

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

        tmp1=bitsra(w,cfType.Log2NumberOfIterations+2);
        ONE=cast(1,'like',w);
        tmp2=cast(ONE-tmp1,'like',w);

        tmp_m1=reinterpretcast(bitsliceget(tmp,w.FractionLength+1,1),numerictype(0,w.FractionLength+1,w.FractionLength));
        tmp_m2=reinterpretcast(bitsliceget(tmp2,w.FractionLength+1,1),numerictype(0,w.FractionLength+1,w.FractionLength));

        appx=cast(tmp_m1*tmp_m2,'like',L);
        if(sign==1)
            appx(:)=-appx;
        end

        shift=cfType.Log2NumberOfIterations+1+cast(j,'like',cfType.Log2NumberOfIterations);
        tmp4=bitsra(appx,shift);
        L(:)=L-tmp4;
    end
end

function[L,w]=log_Main_Iterations(cfType,L,w,LogTable,LogMinusTable)
    for ii=coder.unroll(3:1:cfType.Log2NumberOfIterations)
        [L,w]=log_Iteration(L,w,ii,LogTable,LogMinusTable);
    end
end

function[L,w]=log_Iteration(L,w,ii,LogTable,LogMinusTable)
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
        L(:)=L-LogMinusTable(ii);
    elseif(w_hat<-0.5)

        w(:)=tmp4;
        L(:)=L+LogTable(ii);
    end
end



function[L,w,exp_idx,sticky]=log_Prep(cfType,exp_norm,mant_norm,LogTable)
    exp_idx=fi(exp_norm+cast(cfType.MantissaLength+1,'like',exp_norm),0,cfType.ExponentLength+1,0);

    tmp=(bitsliceget(mant_norm,mant_norm.FractionLength,1)~=0);

    if(tmp)
        ONE=cast(1,'like',mant_norm);
        tmp1=cast(mant_norm-ONE,'like',mant_norm);
        tmp2=bitsll(tmp1,1);
        w=cast(tmp2,'like',mant_norm);
    else
        w=cast(0,'like',mant_norm);
    end

    L=cast(0,'like',LogTable(1));
    sticky=tmp;
end

function[L,w,exp_idx]=log_First_Iteration(L,w,exp_idx)
    if(w>1)

        TWO=cast(2,'like',w);
        w(:)=w-TWO;
        exp_idx(:)=exp_idx+cast(1,'like',exp_idx);
    else

        w(:)=bitsll(w,1);
    end
end

function[L,w]=log_Second_Iteration(L,w,LogTable,LogMinusTable)
    tmp1=cast(bitsra(w,1),'like',w);
    w_hat=reinterpretcast(bitsliceget(w,w.WordLength,w.FractionLength-1),numerictype(1,w.WordLength-w.FractionLength+2,2));

    w(:)=bitsll(w,1);
    TWO=cast(2,'like',w);
    tmp2=cast(TWO+tmp1,'like',w);
    tmp3=cast(w-tmp2,'like',w);
    tmp4=cast(w+tmp2,'like',w);

    if(w_hat>=0.75)

        w(:)=tmp3;
        L(:)=L-LogMinusTable(2);
    elseif(w_hat<-0.5)

        w(:)=tmp4;
        L(:)=L+LogTable(2);
    end
end


function[exp_norm,mant_norm]=log_Normalize_Exp_Mant_Normal(cfType,exp_a,mant_a)
    exp_norm=fi(exp_a,1,cfType.ExponentLength+3,0);
    mant_norm=reinterpretcast(bitconcat(fi(0,0,4,0),mant_a,fi(0,0,2,0)),...
    numerictype(1,5+cfType.MantissaLength+2,cfType.MantissaLength+2));
end


function[exp_norm,mant_norm]=log_Normalize_Exp_Mant_Denormal(cfType,exp_a,mant_a)
    if(bitget(mant_a,mant_a.WordLength)==0)
        ia=int8(mant_a.WordLength)-int8(coder.customfloat.helpers.findFirst1(mant_a));
        exp_norm=fi(1-ia,1,cfType.ExponentLength+3,0);
        mant_a(:)=bitsll(mant_a,ia);
    else
        exp_norm=fi(exp_a,1,cfType.ExponentLength+3,0);
    end

    mant_norm=reinterpretcast(bitconcat(fi(0,0,4,0),mant_a,fi(0,0,2,0)),...
    numerictype(1,5+cfType.MantissaLength+2,cfType.MantissaLength+2));
end


function[exp_norm,mant_norm]=log_Normalize_Exp_Mant(cfType,exp_cor,mant_cor,denormal)
    if(denormal)
        [exp_norm,mant_norm]=log_Normalize_Exp_Mant_Denormal(cfType,exp_cor,mant_cor);
    else
        [exp_norm,mant_norm]=log_Normalize_Exp_Mant_Normal(cfType,exp_cor,mant_cor);
    end
end

function[Sign,Exponent,Mantissa]=log_Inf_or_NaN(cfType,aSign,aExponent,aMantissa)
    if(aExponent==0)&&(aMantissa==0)

        Sign=fi(1,0,1,0);
        Exponent=cfType.Exponent_Inf_or_NaN;
        Mantissa=fi(0,0,cfType.MantissaLength,0);
    elseif(aSign==1)

        Sign=aSign;
        Exponent=cfType.Exponent_Inf_or_NaN;
        Mantissa=cfType.Mantissa_NaN;
    else

        Sign=aSign;
        Exponent=aExponent;
        Mantissa=aMantissa;
    end
end
