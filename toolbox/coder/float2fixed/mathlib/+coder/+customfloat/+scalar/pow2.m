%#codegen








function[Sign,Exponent,Mantissa]=pow2(cfType,aSign,aExponent,aMantissa,denormal,Log2Table,Log2MinusTable,Ln2)
    coder.allowpcode('plain');

    [aExponent,aMantissa]=coder.customfloat.helpers.checkDenormal(cfType,aExponent,aMantissa,denormal);

    if(aExponent==cfType.Exponent_Inf_or_NaN)
        [Sign,Exponent,Mantissa]=pow2_Inf_or_NaN(cfType,aSign,aExponent,aMantissa);
    else
        [exp_cor,mant_cor]=coder.customfloat.helpers.appendMantissaAndCorrectExponent(cfType,aExponent,aMantissa);
        [Sign,Exponent,Mantissa]=pow2_Main(cfType,aSign,exp_cor,mant_cor,denormal,Log2Table,Log2MinusTable,Ln2);
    end
end

function[Sign,Exponent,Mantissa]=pow2_Main(cfType,aSign,exp_cor,mant_cor,denormal,Log2Table,Log2MinusTable,Ln2)

    Sign=fi(0,0,1,0);

    [in_range,mant_ext]=pow2_Check_Exp_Range_and_Shift_Mant(cfType,aSign,exp_cor,mant_cor,denormal);

    if(in_range)
        [exp_out,mant_frac,sticky]=pow2_Extract_Exp_Mant(cfType,aSign,mant_ext);


        [y,w]=pow2_First_Iteration(mant_frac,Log2Table);


        [y,w]=pow2_Main_Iterations(cfType,y,w,Log2Table,Log2MinusTable);


        y=pow2_Final_Approximation(cfType,y,w,Ln2);


        [exp_norm,mant_out]=pow2_Normalize_Answer(cfType,exp_out,y,denormal);


        if(denormal)
            [Exponent,Mantissa]=coder.customfloat.helpers.rounding(exp_norm,mant_out,sticky);
        else
            [Exponent,Mantissa]=coder.customfloat.helpers.rounding_normals(exp_norm,mant_out,sticky);
        end
    else
        Mantissa=fi(0,0,cfType.MantissaLength,0);

        if(aSign)
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

    if bitget(y,cfType.Pow2IntermediatePrec+1)
        exp_norm=fi(exp_out,0,cfType.ExponentLength,0);
    else
        exp_norm=fi(0,0,cfType.ExponentLength,0);
    end

    mant_out=bitsliceget(y,cfType.Pow2IntermediatePrec,cfType.Pow2IntermediatePrec-cfType.MantissaLength);
end

function[exp_norm,mant_out]=pow2_Normalize_Answer_Normals(cfType,exp_out,y)
    if(exp_out>0)
        exp_norm=fi(exp_out,0,cfType.ExponentLength,0);
        mant_out=bitsliceget(y,cfType.Pow2IntermediatePrec,cfType.Pow2IntermediatePrec-cfType.MantissaLength);
    else
        mant_out=fi(0,0,cfType.MantissaLength+1,0);
        if(bitget(y,cfType.Pow2IntermediatePrec)&&(bitget(exp_out,exp_out.WordLength)==0))
            exp_norm=fi(1,0,cfType.ExponentLength,0);
        else
            exp_norm=fi(0,0,cfType.ExponentLength,0);
        end
    end
end


function y=pow2_Final_Approximation(cfType,y,w,Ln2)
    tmp1=reinterpretcast(bitsliceget(w,w.WordLength,cfType.Pow2NumberOfIterations+1),...
    numerictype(1,w.WordLength-cfType.Pow2NumberOfIterations,w.WordLength-cfType.Pow2NumberOfIterations-2));
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


function[y,w]=pow2_Main_Iterations(cfType,y,w,Log2Table,Log2MinusTable)

    for ii=coder.unroll(2:1:cfType.Pow2NumberOfIterations)
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
    mant_frac=reinterpretcast(bitconcat(fi(0,0,2,0),bitsliceget(mant_ext,cfType.Pow2IntermediatePrec,1)),...
    numerictype(1,cfType.Pow2IntermediatePrec+2,cfType.Pow2IntermediatePrec));

    mant_tmp=cast(cast(1,'like',mant_frac)-mant_frac,'like',mant_frac);

    sticky=(bitget(mant_tmp,mant_tmp.WordLength-1)==0);

    exp_tmp=reinterpretcast(bitconcat(fi(0,0,1,0),bitsliceget(mant_ext,mant_ext.WordLength,cfType.Pow2IntermediatePrec+1)),...
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
    exp_tmp=reinterpretcast(bitconcat(fi(0,0,3,0),exp_cor),numerictype(1,cfType.ExponentLength+3,0));
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
        mant_ext=fi(0,0,cfType.ExponentLength+cfType.Pow2IntermediatePrec+1,cfType.Pow2IntermediatePrec);
    else
        in_range=true;

        exp_unbiased=cast(exp_tmp-cast(cfType.ExponentBias,'like',exp_tmp),'like',exp_tmp);

        shift_sign=bitget(exp_unbiased,exp_unbiased.WordLength);

        if(shift_sign)
            shift_length=cast(cast(cfType.ExponentBias,'like',exp_cor)-exp_cor,'like',exp_cor);

            tmp1=bitconcat(mant_cor,fi(0,0,cfType.Pow2IntermediatePrec-cfType.MantissaLength));
            tmp2=coder.customfloat.helpers.safe_bitsra(tmp1,shift_length);
            mant_ext=reinterpretcast(bitconcat(fi(0,0,cfType.ExponentLength,0),tmp2),...
            numerictype(0,cfType.ExponentLength+cfType.Pow2IntermediatePrec+1,cfType.Pow2IntermediatePrec));
        else
            shift_length=cast(exp_unbiased,'like',exp_cor);

            tmp1=bitconcat(fi(0,0,cfType.ExponentLength,0),mant_cor);
            tmp2=bitsll(tmp1,shift_length);
            mant_ext=reinterpretcast(bitconcat(tmp2,fi(0,0,cfType.Pow2IntermediatePrec-cfType.MantissaLength,0)),...
            numerictype(0,cfType.ExponentLength+cfType.Pow2IntermediatePrec+1,cfType.Pow2IntermediatePrec));
        end
    end
end


function[Sign,Exponent,Mantissa]=pow2_Inf_or_NaN(cfType,aSign,aExponent,aMantissa)
    Mantissa=aMantissa;

    if(aMantissa~=0)||(aSign==0)

        Sign=aSign;
        Exponent=aExponent;
    else

        Sign=fi(0,0,1,0);
        Exponent=fi(0,0,cfType.ExponentLength,0);
    end
end
