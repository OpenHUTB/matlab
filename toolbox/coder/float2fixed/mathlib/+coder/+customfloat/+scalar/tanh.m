%#codegen









function[Sign,Exponent,Mantissa]=tanh(cfType,aSign,aExponent,aMantissa,...
    Log2Table,Log2MinusTable,Ln2,Log2_E)
    coder.allowpcode('plain');

    Sign=aSign;

    if((aExponent==cfType.Exponent_Inf_or_NaN)&&(aMantissa~=0))||...
        (aExponent<cfType.ExponentBias-cfType.MantissaLength/2)
        [Exponent,Mantissa]=tanh_Pass_through(cfType,aExponent,aMantissa);
    elseif(aExponent>ceil(log2((log(2)*(double(cfType.MantissaLength)+2)/4)))+cfType.ExponentBias)

        Exponent=fi(cfType.ExponentBias,0,cfType.ExponentLength,0);
        Mantissa=fi(0,0,cfType.MantissaLength,0);
    else
        [exp_cor,mant_cor]=coder.customfloat.helpers.appendMantissaAndCorrectExponent(cfType,aExponent,aMantissa);
        [Exponent,Mantissa]=tanh_Main(cfType,exp_cor,mant_cor,...
        Log2Table,Log2MinusTable,Ln2,Log2_E);
    end
end

function[Exponent,Mantissa]=tanh_Main(cfType,exp_cor,mant_cor,...
    Log2Table,Log2MinusTable,Ln2,Log2_E)






    useCubicApprx=(exp_cor<cfType.ExponentBias-cfType.TanhCubicExponent);

    [exp_m,mant_m]=tanh_Multiply_by_Log2_E(cfType,exp_cor,mant_cor,Log2_E,useCubicApprx);

    mant_ext=tanh_Check_Exp_Range_and_Shift_Mant(cfType,exp_m,mant_m);

    if useCubicApprx






        sticky=true;
        exp_out=fi(exp_cor,1,cfType.ExponentLength+2,0);
        shift_length=fi(fi(2*cfType.ExponentBias,0,cfType.ExponentLength,0)-exp_cor-exp_m,0,8,0);
        tmp=reinterpretcast(mant_cor,numerictype(0,cfType.MantissaLength+1,cfType.MantissaLength));
        ONE=cast(tmp,'like',Log2Table(1));
        y=cast(mant_m,'like',Log2Table(1));
        w=fi(tmp,numerictype(1,cfType.TanhIntermediatePrec+2,cfType.TanhIntermediatePrec));
    else
        [exp_out,shift_length,mant_frac_neg,sticky]=tanh_Extract_Exp_Mant(cfType,mant_ext);



        [y,w]=exp_First_Iteration(mant_frac_neg,Log2Table);


        [y,w]=exp_Main_Iterations(cfType,y,w,Log2Table,Log2MinusTable);

        ONE=cast(1,'like',y);
    end




    y=exp_Final_Approximation_Shared(cfType,y,w,Ln2,useCubicApprx);


    [exp_out,OnePlusE,OneMinusE]=tanh_One_Plus_Minus_E(cfType,exp_out,ONE,y,shift_length);

    if useCubicApprx

        mant_out=bitsliceget(OneMinusE,OneMinusE.FractionLength,OneMinusE.FractionLength-cfType.MantissaLength);
    else


        if(OneMinusE<OnePlusE)
            OneMinusE(:)=bitsll(OneMinusE,1);
            exp_out(:)=exp_out-cast(1,'like',exp_out);
        end
        Q=rdivide_Long_Div(OneMinusE,OnePlusE,cfType.MantissaLength);
        mant_out=bitsliceget(Q,Q.FractionLength,1);
    end

    exp_norm=fi(exp_out,0,cfType.ExponentLength,0);


    [Exponent,Mantissa]=coder.customfloat.helpers.rounding(exp_norm,mant_out,sticky);

end


function Q=rdivide_Long_Div(mant_a_norm,mant_b_norm,ML)
    Q=fi(0,0,ML+2,ML+1);

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


function[exp_out,OnePlusE,OneMinusE]=tanh_One_Plus_Minus_E(cfType,exp_out,ONE,y,shift_length)
    y(:)=coder.customfloat.helpers.safe_bitsra(y,shift_length);
    OneMinusE=cast(ONE-y,'like',ONE);

    OnePlusE=cast(ONE+y,'like',ONE);


    if bitget(OneMinusE,ONE.FractionLength+2)
        exp_out(:)=exp_out+cast(1,'like',exp_out);
        OneMinusE(:)=bitsra(OneMinusE,1);
    else
        tmp=bitsliceget(OneMinusE,OneMinusE.FractionLength+1,OneMinusE.FractionLength-cfType.TanhCubicExponent+1);
        pos=coder.customfloat.helpers.findFirst1(tmp);
        sl=uint8(tmp.WordLength)-pos;
        OneMinusE(:)=bitsll(OneMinusE,sl);
        exp_out(:)=exp_out-cast(sl,'like',exp_out);
    end
end


function y=exp_Final_Approximation_Shared(cfType,y,w,Ln2,useCubicApprx)
    tmp1=reinterpretcast(bitsliceget(w,w.WordLength,cfType.TanhNumberOfIterations+1),...
    numerictype(1,w.WordLength-cfType.TanhNumberOfIterations,w.WordLength-cfType.TanhNumberOfIterations-2));

    if useCubicApprx
        tmp2=cast(1/3,'like',tmp1);
    else
        tmp2=cast(Ln2,'like',tmp1);
    end

    tmp3=cast(tmp1*tmp2,'like',tmp1);
    tmp4=reinterpretcast(bitsliceget(y,y.WordLength-1,y.WordLength-tmp1.WordLength),...
    numerictype(1,tmp1.WordLength,tmp1.FractionLength));
    tmp5=cast(tmp3*tmp4,'like',tmp1);

    if useCubicApprx
        y(:)=cast(tmp5,'like',y);
    else
        if bitget(tmp5,tmp5.WordLength)
            tmp6=fi(-1,1,y.WordLength-tmp5.WordLength,0);
        else
            tmp6=fi(0,1,y.WordLength-tmp5.WordLength,0);
        end
        tmp7=reinterpretcast(bitconcat(tmp6,tmp5),numerictype(1,y.WordLength,y.FractionLength));
        y(:)=y+tmp7;
    end
end


function[y,w]=exp_Main_Iterations(cfType,y,w,Log2Table,Log2MinusTable)
    for ii=coder.unroll(2:1:cfType.TanhNumberOfIterations)
        [y,w]=exp_Iteration(y,w,ii,Log2Table,Log2MinusTable);
    end
end

function[y,w]=exp_Iteration(y,w,ii,Log2Table,Log2MinusTable)
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


function[y,w]=exp_First_Iteration(mant_frac,Log2Table)
    w=cast(bitsll(mant_frac,1),'like',mant_frac);

    if bitget(w,w.WordLength-1)
        w(:)=w-Log2Table(1);
        y=cast(1.5,'like',Log2Table(1));
    else
        y=cast(1,'like',Log2Table(1));
    end
end






function[exp_out,shift_length,mant_frac_neg,sticky]=tanh_Extract_Exp_Mant(cfType,mant_ext)
    mant_frac_neg=reinterpretcast(bitconcat(fi(0,0,2,0),bitsliceget(mant_ext,cfType.TanhIntermediatePrec,1)),...
    numerictype(1,cfType.TanhIntermediatePrec+2,cfType.TanhIntermediatePrec));

    mant_tmp=cast(cast(1,'like',mant_frac_neg)-mant_frac_neg,'like',mant_frac_neg);

    sticky=(bitget(mant_tmp,mant_tmp.WordLength-1)==0);

    extrabits=cfType.ExponentLength+2-(mant_ext.WordLength-cfType.TanhIntermediatePrec);
    exp_tmp=reinterpretcast(bitconcat(fi(0,0,extrabits,0),bitsliceget(mant_ext,mant_ext.WordLength,cfType.TanhIntermediatePrec+1)),...
    numerictype(1,cfType.ExponentLength+2,0));
    exp_adj=fi(cfType.ExponentBias,1,cfType.ExponentLength+2,0);
    exp_out=fi(cfType.ExponentBias,1,cfType.ExponentLength+2,0);

    if(sticky)
        mant_frac_neg(:)=mant_tmp;
        exp_adj=fi(cfType.ExponentBias-1,1,cfType.ExponentLength+2,0);
    end

    exp_out_neg=cast(exp_adj-exp_tmp,'like',exp_tmp);
    shift_length=fi(exp_out-exp_out_neg,numerictype(0,8,0));
end


function mant_ext=tanh_Check_Exp_Range_and_Shift_Mant(cfType,exp_cor,mant_cor)
    exp_tmp=reinterpretcast(bitconcat(fi(0,0,3,0),exp_cor),numerictype(1,cfType.ExponentLength+3,0));
    exp_unbiased=cast(exp_tmp-cast(cfType.ExponentBias-1,'like',exp_tmp),'like',exp_tmp);

    shift_sign=bitget(exp_unbiased,exp_unbiased.WordLength);

    if(shift_sign)
        shift_length=cast(cast(cfType.ExponentBias-1,'like',exp_cor)-exp_cor,'like',exp_cor);

        tmp1=coder.customfloat.helpers.safe_bitsra(mant_cor,shift_length);
        mant_ext=reinterpretcast(bitconcat(fi(0,0,ceil(cfType.ExponentLength/2)+1,0),tmp1),...
        numerictype(0,ceil(cfType.ExponentLength/2)+1+cfType.TanhIntermediatePrec+1,cfType.TanhIntermediatePrec));
    else
        shift_length=cast(exp_unbiased,'like',exp_cor);

        tmp1=bitconcat(fi(0,0,ceil(cfType.ExponentLength/2)+1,0),mant_cor);
        tmp2=bitsll(tmp1,shift_length);
        mant_ext=reinterpretcast(tmp2,...
        numerictype(0,ceil(cfType.ExponentLength/2)+1+cfType.TanhIntermediatePrec+1,cfType.TanhIntermediatePrec));
    end
end


function[exp_m,mant_m]=tanh_Multiply_by_Log2_E(cfType,exp_cor,mant_cor,Log2_E,useCubicApprx)
    tmp1=reinterpretcast(mant_cor,numerictype(0,cfType.MantissaLength+1,cfType.MantissaLength));
    if useCubicApprx



        tmp1_2=cast(tmp1,'like',Log2_E);
    else
        tmp1_2=Log2_E;
    end
    tmp2=cast(tmp1*tmp1_2,'like',fi(0,0,cfType.TanhIntermediatePrec+2,cfType.TanhIntermediatePrec));

    if(bitget(tmp2,tmp2.WordLength)==1)
        exp_m=cast(exp_cor+cast(1,'like',exp_cor),'like',exp_cor);
        mant_m=reinterpretcast(bitsliceget(tmp2,tmp2.WordLength,2),numerictype(0,tmp2.WordLength-1,tmp2.WordLength-2));
    else
        exp_m=exp_cor;
        mant_m=reinterpretcast(bitsliceget(tmp2,tmp2.WordLength-1,1),numerictype(0,tmp2.WordLength-1,tmp2.WordLength-2));
    end
end



function[Exponent,Mantissa]=tanh_Pass_through(~,aExponent,aMantissa)
    Exponent=aExponent;
    Mantissa=aMantissa;
end
