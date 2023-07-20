%#codegen









function[Sign,Exponent,Mantissa]=sinh(cfType,aSign,aExponent,aMantissa,...
    Log2Table,Log2MinusTable,Ln2,Log2_E)
    coder.allowpcode('plain');

    Sign=aSign;

    if(aExponent==cfType.Exponent_Inf_or_NaN)||(aExponent<cfType.ExponentBias-cfType.MantissaLength/2)
        [Exponent,Mantissa]=sinh_Inf_or_NaN(cfType,aExponent,aMantissa);
    else
        [exp_cor,mant_cor]=coder.customfloat.helpers.appendMantissaAndCorrectExponent(cfType,aExponent,aMantissa);
        [Exponent,Mantissa]=sinh_Main(cfType,exp_cor,mant_cor,...
        Log2Table,Log2MinusTable,Ln2,Log2_E);
    end
end

function[Exponent,Mantissa]=sinh_Main(cfType,exp_cor,mant_cor,...
    Log2Table,Log2MinusTable,Ln2,Log2_E)




    useCubicApprx=(exp_cor<cfType.ExponentBias-cfType.SinhCubicExponent);

    [exp_m,mant_m]=sinh_Multiply_by_Log2_E(cfType,exp_cor,mant_cor,Log2_E,useCubicApprx);

    [in_range,mant_ext]=sinh_Check_Exp_Range_and_Shift_Mant(cfType,exp_m,mant_m);

    if(in_range)
        if useCubicApprx






            sticky=true;
            exp_out=fi(exp_cor+cast(1,'like',exp_cor),1,cfType.ExponentLength+2,0);
            shift_length=fi(fi(2*cfType.ExponentBias+1,0,cfType.ExponentLength,0)-exp_cor-exp_m,0,8,0);
            tmp=reinterpretcast(mant_cor,numerictype(0,cfType.MantissaLength+1,cfType.MantissaLength));
            y_pos=cast(tmp,'like',Log2Table(1));
            y_neg=cast(mant_m,'like',Log2Table(1));
            w_neg=fi(tmp,numerictype(1,cfType.SinhIntermediatePrec+2,cfType.SinhIntermediatePrec));
        else
            [exp_out,shift_length,mant_frac_pos,mant_frac_neg,sticky]=sinh_Extract_Exp_Mant(cfType,mant_ext);



            [y_pos,w_pos]=exp_First_Iteration(mant_frac_pos,Log2Table);


            [y_pos,w_pos]=exp_Main_Iterations(cfType,y_pos,w_pos,Log2Table,Log2MinusTable);


            y_pos=exp_Final_Approximation(cfType,y_pos,w_pos,Ln2);



            [y_neg,w_neg]=exp_First_Iteration(mant_frac_neg,Log2Table);


            [y_neg,w_neg]=exp_Main_Iterations(cfType,y_neg,w_neg,Log2Table,Log2MinusTable);
        end



        y_neg=exp_Final_Approximation_Shared(cfType,y_neg,w_neg,Ln2,useCubicApprx);



        [exp_norm,mant_out]=sinh_Add_pos_neg_parts(cfType,exp_out,y_pos,y_neg,shift_length);


        [Exponent,Mantissa]=coder.customfloat.helpers.rounding(exp_norm,mant_out,sticky);


        if(bitcmp(Exponent)==0)
            Mantissa(:)=0;
        end
    else
        Mantissa=fi(0,0,cfType.MantissaLength,0);

        Exponent=cfType.Exponent_Inf_or_NaN;
    end
end


function[exp_norm,mant_out]=sinh_Add_pos_neg_parts(cfType,exp_out,y_pos,y_neg,shift_length)
    y_neg(:)=coder.customfloat.helpers.safe_bitsra(y_neg,shift_length);
    y_pos(:)=y_pos-y_neg;

    tmp=bitsliceget(y_pos,cfType.SinhIntermediatePrec+2,cfType.SinhIntermediatePrec-cfType.SinhCubicExponent+1);
    pos=coder.customfloat.helpers.findFirst1(tmp);
    shift_length=uint8(tmp.WordLength)-pos;

    exp_norm=fi(exp_out-cast(shift_length,'like',exp_out),0,cfType.ExponentLength,0);

    y_pos(:)=bitsll(y_pos,shift_length);
    mant_out=bitsliceget(y_pos,cfType.SinhIntermediatePrec+1,cfType.SinhIntermediatePrec-cfType.MantissaLength+1);

end


function y=exp_Final_Approximation_Shared(cfType,y,w,Ln2,useCubicApprx)
    tmp1=reinterpretcast(bitsliceget(w,w.WordLength,cfType.SinhNumberOfIterations+1),...
    numerictype(1,w.WordLength-cfType.SinhNumberOfIterations,w.WordLength-cfType.SinhNumberOfIterations-2));

    if useCubicApprx
        tmp2=cast(-1/3,'like',tmp1);
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


function y=exp_Final_Approximation(cfType,y,w,Ln2)
    tmp1=reinterpretcast(bitsliceget(w,w.WordLength,cfType.SinhNumberOfIterations+1),...
    numerictype(1,w.WordLength-cfType.SinhNumberOfIterations,w.WordLength-cfType.SinhNumberOfIterations-2));
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

    for ii=coder.unroll(2:1:cfType.SinhNumberOfIterations)
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






function[exp_out,shift_length,mant_frac_pos,mant_frac_neg,sticky]=sinh_Extract_Exp_Mant(cfType,mant_ext)
    mant_frac_pos=reinterpretcast(bitconcat(fi(0,0,2,0),bitsliceget(mant_ext,cfType.SinhIntermediatePrec,1)),...
    numerictype(1,cfType.SinhIntermediatePrec+2,cfType.SinhIntermediatePrec));

    mant_frac_neg=mant_frac_pos;

    mant_tmp=cast(cast(1,'like',mant_frac_neg)-mant_frac_neg,'like',mant_frac_neg);

    sticky=(bitget(mant_tmp,mant_tmp.WordLength-1)==0);

    exp_tmp=reinterpretcast(bitconcat(fi(0,0,1,0),bitsliceget(mant_ext,mant_ext.WordLength,cfType.SinhIntermediatePrec+1)),...
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


function[in_range,mant_ext]=sinh_Check_Exp_Range_and_Shift_Mant(cfType,exp_cor,mant_cor)
    exp_tmp=reinterpretcast(bitconcat(fi(0,0,3,0),exp_cor),numerictype(1,cfType.ExponentLength+3,0));
    upperBound=coder.const(int16(ceil(log2(2^(double(cfType.ExponentLength))-...
    double(cfType.ExponentBias))))+int16(cfType.ExponentBias));

    if(exp_tmp>=upperBound)
        in_range=false;
        mant_ext=fi(0,0,cfType.ExponentLength+cfType.SinhIntermediatePrec+1,cfType.SinhIntermediatePrec);
    else
        in_range=true;

        exp_unbiased=cast(exp_tmp-cast(cfType.ExponentBias,'like',exp_tmp),'like',exp_tmp);

        shift_sign=bitget(exp_unbiased,exp_unbiased.WordLength);

        if(shift_sign)
            shift_length=cast(cast(cfType.ExponentBias,'like',exp_cor)-exp_cor,'like',exp_cor);

            tmp1=coder.customfloat.helpers.safe_bitsra(mant_cor,shift_length);
            mant_ext=reinterpretcast(bitconcat(fi(0,0,cfType.ExponentLength,0),tmp1),...
            numerictype(0,cfType.ExponentLength+cfType.SinhIntermediatePrec+1,cfType.SinhIntermediatePrec));
        else
            shift_length=cast(exp_unbiased,'like',exp_cor);

            tmp1=bitconcat(fi(0,0,cfType.ExponentLength,0),mant_cor);
            tmp2=bitsll(tmp1,shift_length);
            mant_ext=reinterpretcast(tmp2,...
            numerictype(0,cfType.ExponentLength+cfType.SinhIntermediatePrec+1,cfType.SinhIntermediatePrec));
        end
    end
end


function[exp_m,mant_m]=sinh_Multiply_by_Log2_E(cfType,exp_cor,mant_cor,Log2_E,useCubicApprx)
    tmp1=reinterpretcast(mant_cor,numerictype(0,cfType.MantissaLength+1,cfType.MantissaLength));
    if useCubicApprx



        tmp1_2=cast(tmp1,'like',Log2_E);
    else
        tmp1_2=Log2_E;
    end
    tmp2=cast(tmp1*tmp1_2,'like',fi(0,0,cfType.SinhIntermediatePrec+2,cfType.SinhIntermediatePrec));

    if(bitget(tmp2,tmp2.WordLength)==1)
        exp_m=cast(exp_cor+cast(1,'like',exp_cor),'like',exp_cor);
        mant_m=reinterpretcast(bitsliceget(tmp2,tmp2.WordLength,2),numerictype(0,tmp2.WordLength-1,tmp2.WordLength-2));
    else
        exp_m=exp_cor;
        mant_m=reinterpretcast(bitsliceget(tmp2,tmp2.WordLength-1,1),numerictype(0,tmp2.WordLength-1,tmp2.WordLength-2));
    end
end



function[Exponent,Mantissa]=sinh_Inf_or_NaN(~,aExponent,aMantissa)
    Exponent=aExponent;
    Mantissa=aMantissa;
end
