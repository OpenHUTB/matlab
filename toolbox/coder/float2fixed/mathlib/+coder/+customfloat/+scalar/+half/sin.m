%#codegen








function[Sign,Exponent,Mantissa]=sin(cfType,aSign,aExponent,aMantissa,TwoOverPi,SinTwoOverPiTable,SinLinearApproxSlope,...
    SinLinearApproxIntercept,OutOfRangeConstExponent,OutOfRangeConstMantissa,ArgRed)

    coder.allowpcode('plain');


    MANT_REDUCED_LENGTH=cfType.MantissaLength+3;


    if outOfRangeCheck(cfType,aExponent,aMantissa,OutOfRangeConstExponent,OutOfRangeConstMantissa,ArgRed)
        Sign=aSign;
        Exponent=cfType.Exponent_Inf_or_NaN;
        Mantissa=cfType.Mantissa_NaN;
    else
        [exp_cor,mant_cor]=coder.customfloat.helpers.appendMantissaAndCorrectExponent(cfType,aExponent,aMantissa);


        [exp_norm,mant_norm]=trig_Normalize_Exp_Mant(cfType,exp_cor,mant_cor);


        [exp_reduced,mant_reduced,k]=rangeReduceSin(exp_norm,mant_norm,TwoOverPi,SinTwoOverPiTable,MANT_REDUCED_LENGTH);


        [slope,intercept,reduced_angle]=binary_search(exp_reduced,mant_reduced,MANT_REDUCED_LENGTH,SinLinearApproxSlope,SinLinearApproxIntercept);


        approx=linear_approx(reduced_angle,slope,intercept);


        [Exponent,Mantissa]=Normalize_answer(cfType,approx);


        [Exponent,Mantissa]=coder.customfloat.helpers.rounding(Exponent,Mantissa,true);


        Sign=bitxor(bitget(k,2),aSign);
    end
end




function[exp_norm,mant_norm]=trig_Normalize_Exp_Mant(cfType,exp_a,mant_a)
    if(bitget(mant_a,mant_a.WordLength)==0)
        ia=int8(mant_a.WordLength)-int8(coder.customfloat.helpers.findFirst1(mant_a));
        exp_norm=fi(1-ia,1,cfType.ExponentLength+1,0);
        mant_a(:)=coder.customfloat.helpers.safe_bitsll(mant_a,ia);
    else
        exp_norm=fi(exp_a,1,cfType.ExponentLength+1,0);
    end
    mant_norm=reinterpretcast(mant_a,numerictype(0,cfType.MantissaLength+1,cfType.MantissaLength));
end

















function[exp_reduced,mant_reduced,k]=rangeReduceSin(exp,mant,TwoOverPi,SinTwoOverPiTable,MANT_REDUCED_LENGTH)
    if exp<15
        prod_frac_length=mant.FractionLength+TwoOverPi.FractionLength;
        prod=mant*TwoOverPi;
        if bitget(prod,prod_frac_length+1)
            mant_reduced_sliced=bitsliceget(prod,prod_frac_length+1,prod_frac_length+1-MANT_REDUCED_LENGTH);
            exp_reduced=exp;
        else
            prod_shifted=bitsll(prod,1);
            mant_reduced_sliced=bitsliceget(prod_shifted,prod_frac_length+1,prod_frac_length+1-MANT_REDUCED_LENGTH);
            exp_reduced=cast(exp-cast(1,'like',exp),'like',exp);
        end
        mant_reduced=reinterpretcast(mant_reduced_sliced,numerictype(0,mant_reduced_sliced.WordLength,MANT_REDUCED_LENGTH));
        k=fi(0,0,2,0);
    else
        prod_frac_length_table=mant.FractionLength+SinTwoOverPiTable.FractionLength;
        offset=fi(14,0,4,0);
        idx=exp-offset;
        prod=mant*SinTwoOverPiTable(idx);

        k=fi(bitsliceget(prod,prod_frac_length_table+2,prod_frac_length_table+1),0,2,0);
        fractional_part=bitsliceget(prod,prod_frac_length_table);
        if k==1||k==3
            one=fi(bitset(0,prod_frac_length_table+1),0,prod_frac_length_table+1,0);
            fractional_part(:)=one-fractional_part;
        end
        pos=coder.customfloat.helpers.findFirst1(fractional_part);
        mant_shifted=bitsll(fractional_part,uint8(fractional_part.WordLength-pos));
        mant_reduced_sliced=bitsliceget(mant_shifted,mant_shifted.WordLength,mant_shifted.WordLength-MANT_REDUCED_LENGTH);
        mant_reduced=reinterpretcast(mant_reduced_sliced,numerictype(0,mant_reduced_sliced.WordLength,MANT_REDUCED_LENGTH));
        exp_reduced=cast(15-int8(prod_frac_length_table+1-pos),'like',exp);
    end
end

















function[slope,intercept,reduced_angle]=binary_search(exp_reduced,mant_reduced,MANT_REDUCED_LENGTH,SinLinearApproxSlope,SinLinearApproxIntercept)
    reduced_angle=fi(mant_reduced,0,15+MANT_REDUCED_LENGTH,14+MANT_REDUCED_LENGTH);
    if exp_reduced<15
        reduced_angle=bitsrl(reduced_angle,cast(15,'like',exp_reduced)-exp_reduced);
    else
        reduced_angle=bitsll(reduced_angle,exp_reduced-cast(15,'like',exp_reduced));
    end



    left_idx=fi((bitsliceget(reduced_angle,reduced_angle.WordLength-1,reduced_angle.WordLength-5)+fi(1,0,5,0)),0,6,0);
    slope=SinLinearApproxSlope(left_idx);
    intercept=SinLinearApproxIntercept(left_idx);
end











function approx=linear_approx(reduced_angle,slope,intercept)
    approx=slope*reduced_angle+intercept;

    approx=fi(approx,0,25,24);
end



function[Exponent,Mantissa]=Normalize_answer(cfType,approx)
    pos=coder.customfloat.helpers.findFirst1(approx);
    bit_shift_length=approx.WordLength-pos;
    Exponent=fi(15-int8(bit_shift_length),1,cfType.ExponentLength+1,0);
    Mantissa=coder.customfloat.helpers.safe_bitsll(approx,bit_shift_length);
    if Exponent<=0
        Mantissa=bitsrl(Mantissa,abs(Exponent)+cast(1,'like',Exponent));
        Exponent(:)=0;
    end
    Mantissa=bitsliceget(Mantissa,Mantissa.WordLength-1,Mantissa.WordLength-1-cfType.MantissaLength);
    Mantissa=reinterpretcast(Mantissa,numerictype(0,Mantissa.WordLength,Mantissa.WordLength));
    Exponent=fi(Exponent,0,cfType.ExponentLength,0);
end















function flag=outOfRangeCheck(cfType,aExponent,aMantissa,OutOfRangeConstExponent,OutOfRangeConstMantissa,ArgRed)
    if(aExponent==cfType.Exponent_Inf_or_NaN)
        flag=true;
    elseif ArgRed==false
        if(aExponent>OutOfRangeConstExponent)
            flag=true;
        elseif(aExponent==OutOfRangeConstExponent)&&(aMantissa>OutOfRangeConstMantissa)
            flag=true;
        else
            flag=false;
        end
    else
        flag=false;
    end
end

