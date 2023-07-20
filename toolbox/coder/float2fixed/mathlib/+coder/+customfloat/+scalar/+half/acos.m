%#codegen








function[Sign,Exponent,Mantissa]=acos(cfType,aSign,aExponent,aMantissa,Pi,PiExponent,PiMantissa,...
    AcosApproxSlopeTable,AcosApproxInterceptTable,AcosLookupTablePos,AcosLookupTableNeg)

    coder.allowpcode('plain');


    if(aExponent==cfType.Exponent_Inf_or_NaN)||...
        outOfRangeCheck(aExponent,aMantissa,cfType.ExponentBias,fi(0,0,cfType.MantissaLength,0))
        Sign=aSign;
        Exponent=cfType.Exponent_Inf_or_NaN;
        Mantissa=cfType.Mantissa_NaN;
    else
        [exp_cor,mant_cor]=coder.customfloat.helpers.appendMantissaAndCorrectExponent(cfType,aExponent,aMantissa);


        [exp_norm,mant_norm]=trig_Normalize_Exp_Mant(cfType,exp_cor,mant_cor);


        [angle,left_idx]=binary_search(cfType,exp_norm,mant_norm);


        if left_idx<21

            approx=linear_approx(angle,AcosApproxSlopeTable(left_idx),AcosApproxInterceptTable(left_idx));


            [Exponent,Mantissa]=Normalize_answer(cfType,approx,Pi,aSign);


            [Exponent,Mantissa]=coder.customfloat.helpers.rounding(Exponent,Mantissa,true);


        else
            [Exponent,Mantissa]=lookuptable(cfType,aSign,aExponent,aMantissa,PiExponent,PiMantissa,...
            AcosLookupTablePos,AcosLookupTableNeg);
        end


        Sign=fi(0,0,1,0);
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














function[angle,left_idx]=binary_search(cfType,exp_norm,mant_norm)
    if mant_norm==1&&exp_norm==cfType.ExponentBias
        angle=fi(1,0,12,11);
        left_idx=fi(31,0,5,0);
    else
        angle=fi(mant_norm,0,12,11);
        angle=coder.customfloat.helpers.safe_bitsra(angle,cast(15,'like',exp_norm)-exp_norm);

        if bitget(angle,angle.WordLength-1)==0
            left_idx=fi((bitsliceget(angle,angle.WordLength-1,angle.WordLength-4)+fi(1,0,4,0)),0,5,0);

        else
            left_idx=fi((bitsliceget(angle,angle.WordLength-2,angle.WordLength-5)+fi(9,0,4,0)),0,5,0);
        end
    end
end














function approx=linear_approx(angle,slope,intercept)
    approx=slope*angle+intercept;

    approx=fi(approx,0,13,11);
end










function[Exponent,Mantissa]=Normalize_answer(cfType,approx,Pi,aSign)
    if aSign
        approx(:)=Pi-approx;
        if bitget(approx,approx.WordLength)
            Mantissa=approx;
            Exponent=fi(cfType.ExponentBias+cast(1,'like',cfType.ExponentBias),1,cfType.ExponentLength+1,0);
        else
            Mantissa=bitsll(approx,1);
            Exponent=fi(cfType.ExponentBias,1,cfType.ExponentLength+1,0);
        end
    else
        pos=coder.customfloat.helpers.findFirst1(approx);
        if pos>approx.FractionLength
            bit_shift_length=pos-approx.FractionLength;
            Exponent=fi(14+int8(bit_shift_length),1,cfType.ExponentLength+1,0);
            if pos==approx.WordLength
                Mantissa=approx;
            else
                Mantissa=coder.customfloat.helpers.safe_bitsll(approx,bit_shift_length);
            end
        else
            bit_shift_length=approx.WordLength-pos;
            Exponent=fi(15-int8(bit_shift_length)+1,1,cfType.ExponentLength+1,0);
            Mantissa=coder.customfloat.helpers.safe_bitsll(approx,bit_shift_length);
            if Exponent<=0
                Mantissa=bitsrl(Mantissa,abs(Exponent)+cast(1,'like',Exponent));
                Exponent(:)=0;
            end
        end
    end
    Mantissa=bitsliceget(Mantissa,Mantissa.WordLength-1,Mantissa.WordLength-1-cfType.MantissaLength);
    Exponent=fi(Exponent,0,cfType.ExponentLength,0);
end











function[Exponent,Mantissa]=lookuptable(cfType,aSign,aExponent,aMantissa,PiExponent,PiMantissa,...
    AcosLookupTablePos,AcosLookupTableNeg)
    if aExponent==cfType.ExponentBias&&aMantissa==0
        if aSign
            Exponent=PiExponent;
            Mantissa=PiMantissa;
        else
            Exponent=fi(0,0,cfType.ExponentLength,0);
            Mantissa=fi(0,0,cfType.MantissaLength,0);
        end
    else
        if aSign
            offset=uint16(47871);
            index=storedInteger(bitconcat(fi(1,0,1,0),aExponent,aMantissa))-offset;
            Exponent=fi(16,0,5,0);
            Mantissa=AcosLookupTableNeg(index);
        else
            offset=uint16(15103);
            index=storedInteger(bitconcat(fi(0,0,1,0),aExponent,aMantissa))-offset;
            Exponent=bitsliceget(AcosLookupTablePos(index),15,11);
            Mantissa=bitsliceget(AcosLookupTablePos(index),10);
        end
    end
end











function flag=outOfRangeCheck(aExponent,aMantissa,OutOfRangeConstExponent,OutOfRangeConstMantissa)

    if(aExponent>OutOfRangeConstExponent)
        flag=true;
    elseif(aExponent==OutOfRangeConstExponent)&&(aMantissa>OutOfRangeConstMantissa)
        flag=true;
    else
        flag=false;
    end

end