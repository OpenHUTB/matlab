%#codegen



function[Sign,Exponent,Mantissa]=fixed2cf(cfType,inFixed)

    coder.allowpcode('plain');

    if(inFixed==0)

        Sign=fi(0,0,1,0);
        Exponent=fi(0,0,cfType.ExponentLength,0);
        Mantissa=fi(0,0,cfType.MantissaLength,0);
    else
        inFixed_unsigned=reinterpretcast(inFixed,numerictype(0,inFixed.WordLength,0));
        WL=int16(inFixed.WordLength);

        if issigned(inFixed)
            Sign=bitget(inFixed,inFixed.WordLength);
            if(Sign)


                inFixed_unsigned(:)=bitcmp(inFixed_unsigned)+cast(1,'like',inFixed_unsigned);
            end
        else
            Sign=fi(0,0,1,0);
        end

        inExponent=(WL+int16(cfType.ExponentBias)-1)-int16(inFixed.FractionLength);


        pos=int16(coder.customfloat.helpers.findFirst1(inFixed_unsigned));
        shift_length=int16(WL)-pos;

        inExponent(:)=inExponent-shift_length;
        inFixed_unsigned(:)=bitsll(inFixed_unsigned,shift_length);


        sticky=false;

        if(WL>cfType.MantissaLength+2)
            sticky=(bitsliceget(inFixed_unsigned,WL-int16(cfType.MantissaLength)-2,1)~=0);
            mant=bitsliceget(inFixed_unsigned,WL,WL-int16(cfType.MantissaLength)-1);
        elseif(WL<cfType.MantissaLength+2)
            mant=bitconcat(bitsliceget(inFixed_unsigned,WL,1),fi(0,0,int16(cfType.MantissaLength+2)-WL,0));
        else
            mant=bitsliceget(inFixed_unsigned,WL,1);
        end

        if inExponent>int16(cfType.Exponent_Inf_or_NaN)
            Exponent=cfType.Exponent_Inf_or_NaN;
            mant(:)=0;
        elseif(inExponent<=0)
            Exponent=fi(0,0,cfType.ExponentLength,0);

            sl=int8(1)-int8(inExponent);
            sticky(:)=sticky||(bitsll(mant,mant.WordLength-sl)~=0);
            mant(:)=bitsrl(mant,sl);
        else
            Exponent=fi(inExponent,0,cfType.ExponentLength,0);
        end

        mant_norm=bitsliceget(mant,mant.WordLength-1,1);


        [Exponent,Mantissa]=coder.customfloat.helpers.rounding(Exponent,mant_norm,sticky);
    end
end
