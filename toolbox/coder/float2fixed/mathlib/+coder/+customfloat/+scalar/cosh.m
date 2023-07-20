%#codegen









function[Sign,Exponent,Mantissa]=cosh(cfType,aSign,aExponent,aMantissa,...
    Log2Table,Log2MinusTable,Ln2,Log2_E)
    coder.allowpcode('plain');

    if(aExponent==cfType.Exponent_Inf_or_NaN)
        [Sign,Exponent,Mantissa]=cosh_Inf_or_NaN(cfType,aSign,aExponent,aMantissa);
    else
        [exp_cor,mant_cor]=coder.customfloat.helpers.appendMantissaAndCorrectExponent(cfType,aExponent,aMantissa);
        [Sign,Exponent,Mantissa]=cosh_Main(cfType,aSign,exp_cor,mant_cor,...
        Log2Table,Log2MinusTable,Ln2,Log2_E);
    end
end

function[Sign,Exponent,Mantissa]=cosh_Main(cfType,~,exp_cor,mant_cor,...
    Log2Table,Log2MinusTable,Ln2,Log2_E)

    Sign=fi(0,0,1,0);

    [exp_m,mant_m]=cosh_Multiply_by_Log2_E(cfType,exp_cor,mant_cor,Log2_E);

    [in_range,mant_ext]=cosh_Check_Exp_Range_and_Shift_Mant(cfType,exp_m,mant_m);

    if(in_range)
        [exp_out,shift_length,mant_frac_pos,mant_frac_neg,sticky]=cosh_Extract_Exp_Mant(cfType,mant_ext);



        [y_pos,w_pos]=exp_First_Iteration(mant_frac_pos,Log2Table);


        [y_pos,w_pos]=exp_Main_Iterations(cfType,y_pos,w_pos,Log2Table,Log2MinusTable);


        y_pos=exp_Final_Approximation(cfType,y_pos,w_pos,Ln2);



        [y_neg,w_neg]=exp_First_Iteration(mant_frac_neg,Log2Table);


        [y_neg,w_neg]=exp_Main_Iterations(cfType,y_neg,w_neg,Log2Table,Log2MinusTable);


        y_neg=exp_Final_Approximation(cfType,y_neg,w_neg,Ln2);



        [exp_norm,mant_out]=cosh_Add_pos_neg_parts(cfType,exp_out,y_pos,y_neg,shift_length);


        [Exponent,Mantissa]=coder.customfloat.helpers.rounding(exp_norm,mant_out,sticky);


        if(bitcmp(Exponent)==0)
            Mantissa(:)=0;
        end
    else
        Mantissa=fi(0,0,cfType.MantissaLength,0);

        Exponent=cfType.Exponent_Inf_or_NaN;
    end
end


function[exp_norm,mant_out]=cosh_Add_pos_neg_parts(cfType,exp_out,y_pos,y_neg,shift_length)
    y_neg(:)=coder.customfloat.helpers.safe_bitsra(y_neg,shift_length);
    y_pos(:)=y_pos+y_neg;

    if(bitget(y_pos,cfType.Pow10IntermediatePrec+2))

        exp_norm=fi(exp_out,0,cfType.ExponentLength,0);
        mant_out=bitsliceget(y_pos,cfType.Pow10IntermediatePrec+1,cfType.Pow10IntermediatePrec-cfType.MantissaLength+1);
    else
        exp_norm=fi(exp_out-cast(1,'like',exp_out),0,cfType.ExponentLength,0);
        mant_out=bitsliceget(y_pos,cfType.Pow10IntermediatePrec,cfType.Pow10IntermediatePrec-cfType.MantissaLength);
    end
end


function y=exp_Final_Approximation(cfType,y,w,Ln2)
    tmp1=reinterpretcast(bitsliceget(w,w.WordLength,cfType.Pow10NumberOfIterations+1),...
    numerictype(1,w.WordLength-cfType.Pow10NumberOfIterations,w.WordLength-cfType.Pow10NumberOfIterations-2));
    tmp2=cast(Ln2,'like',tmp1);
    tmp3=cast(tmp1*tmp2,'like',tmp1);
    tmp4=reinterpretcast(bitsliceget(y,y.WordLength-1,y.WordLength-tmp1.WordLength),...
    numerictype(1,tmp1.WordLength,tmp1.FractionLength));
    tmp5=cast(tmp3*tmp4,'like',tmp1);
    if bitget(tmp5,tmp5.WordLength)
        tmp6=fi(-1,1,y.WordLength-tmp5.WordLength,0);
    else
        tmp6=fi(0,1,y.WordLength-tmp5.WordLength,0);
    end
    tmp7=reinterpretcast(bitconcat(tmp6,tmp5),numerictype(1,y.WordLength,y.FractionLength));
    y(:)=y+tmp7;
end


function[y,w]=exp_Main_Iterations(cfType,y,w,Log2Table,Log2MinusTable)

    for ii=coder.unroll(2:1:cfType.Pow10NumberOfIterations)
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






function[exp_out,shift_length,mant_frac_pos,mant_frac_neg,sticky]=cosh_Extract_Exp_Mant(cfType,mant_ext)
    mant_frac_pos=reinterpretcast(bitconcat(fi(0,0,2,0),bitsliceget(mant_ext,cfType.Pow10IntermediatePrec,1)),...
    numerictype(1,cfType.Pow10IntermediatePrec+2,cfType.Pow10IntermediatePrec));

    mant_frac_neg=mant_frac_pos;

    mant_tmp=cast(cast(1,'like',mant_frac_neg)-mant_frac_neg,'like',mant_frac_neg);

    sticky=(bitget(mant_tmp,mant_tmp.WordLength-1)==0);

    exp_tmp=reinterpretcast(bitconcat(fi(0,0,1,0),bitsliceget(mant_ext,mant_ext.WordLength,cfType.Pow10IntermediatePrec+1)),...
    numerictype(1,cfType.ExponentLength+2,0));
    exp_adj=fi(cfType.ExponentBias,1,cfType.ExponentLength+2,0);
    exp_out=cast(exp_adj+exp_tmp,'like',exp_tmp);

    if(sticky)
        mant_frac_neg(:)=mant_tmp;
        exp_adj=fi(cfType.ExponentBias-1,1,cfType.ExponentLength+2,0);
    end

    exp_out_neg=cast(exp_adj-exp_tmp,'like',exp_tmp);
    shift_length=fi(exp_out-exp_out_neg,numerictype(0,8,0));
end


function[in_range,mant_ext]=cosh_Check_Exp_Range_and_Shift_Mant(cfType,exp_cor,mant_cor)
    exp_tmp=reinterpretcast(bitconcat(fi(0,0,3,0),exp_cor),numerictype(1,cfType.ExponentLength+3,0));
    upperBound=coder.const(int16(ceil(log2(2^(double(cfType.ExponentLength))-...
    double(cfType.ExponentBias))))+int16(cfType.ExponentBias));

    if(exp_tmp>=upperBound)
        in_range=false;
        mant_ext=fi(0,0,cfType.ExponentLength+cfType.Pow10IntermediatePrec+1,cfType.Pow10IntermediatePrec);
    else
        in_range=true;

        exp_unbiased=cast(exp_tmp-cast(cfType.ExponentBias,'like',exp_tmp),'like',exp_tmp);

        shift_sign=bitget(exp_unbiased,exp_unbiased.WordLength);

        if(shift_sign)
            shift_length=cast(cast(cfType.ExponentBias,'like',exp_cor)-exp_cor,'like',exp_cor);

            tmp1=coder.customfloat.helpers.safe_bitsra(mant_cor,shift_length);
            mant_ext=reinterpretcast(bitconcat(fi(0,0,cfType.ExponentLength,0),tmp1),...
            numerictype(0,cfType.ExponentLength+cfType.Pow10IntermediatePrec+1,cfType.Pow10IntermediatePrec));
        else
            shift_length=cast(exp_unbiased,'like',exp_cor);

            tmp1=bitconcat(fi(0,0,cfType.ExponentLength,0),mant_cor);
            tmp2=bitsll(tmp1,shift_length);
            mant_ext=reinterpretcast(tmp2,...
            numerictype(0,cfType.ExponentLength+cfType.Pow10IntermediatePrec+1,cfType.Pow10IntermediatePrec));
        end
    end
end


function[exp_m,mant_m]=cosh_Multiply_by_Log2_E(cfType,exp_cor,mant_cor,Log2_E)
    tmp1=reinterpretcast(mant_cor,numerictype(0,cfType.MantissaLength+1,cfType.MantissaLength));
    tmp2=cast(tmp1*Log2_E,'like',fi(0,0,cfType.Pow10IntermediatePrec+2,cfType.Pow10IntermediatePrec));

    if(bitget(tmp2,tmp2.WordLength)==1)
        exp_m=cast(exp_cor+cast(1,'like',exp_cor),'like',exp_cor);
        mant_m=reinterpretcast(bitsliceget(tmp2,tmp2.WordLength,2),numerictype(0,tmp2.WordLength-1,tmp2.WordLength-2));
    else
        exp_m=exp_cor;
        mant_m=reinterpretcast(bitsliceget(tmp2,tmp2.WordLength-1,1),numerictype(0,tmp2.WordLength-1,tmp2.WordLength-2));
    end
end


function[Sign,Exponent,Mantissa]=cosh_Inf_or_NaN(~,aSign,aExponent,aMantissa)


    Sign=fi((aMantissa~=0)&&aSign,0,1,0);
    Exponent=aExponent;
    Mantissa=aMantissa;
end
