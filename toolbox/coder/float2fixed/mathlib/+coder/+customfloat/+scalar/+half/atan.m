%#codegen








function[Sign,Exponent,Mantissa]=atan(cfType,aSign,aExponent,aMantissa,PiOverTwo,PiOverTwoExponent,PiOverTwoMantissa,...
    AtanApproxSlopeTable,AtanApproxInterceptTable)

    coder.allowpcode('plain');


    if(aExponent==cfType.Exponent_Inf_or_NaN)
        if aMantissa==0
            Exponent=PiOverTwoExponent;
            Mantissa=PiOverTwoMantissa;
        else
            Exponent=cfType.Exponent_Inf_or_NaN;
            Mantissa=cfType.Mantissa_NaN;
        end

    elseif(aExponent<10)||(aExponent==10&&aMantissa<668)
        Exponent=aExponent;
        Mantissa=aMantissa;


    elseif aExponent==11&&aMantissa==0
        Exponent=fi(10,0,5,0);
        Mantissa=fi(1021,0,10,0);
    elseif aExponent==12&&aMantissa==0
        Exponent=fi(11,0,5,0);
        Mantissa=fi(1013,0,10,0);
    elseif aExponent==12&&aMantissa==1
        Exponent=fi(11,0,5,0);
        Mantissa=fi(1015,0,10,0);
    elseif aExponent==12&&aMantissa==2
        Exponent=fi(11,0,5,0);
        Mantissa=fi(1017,0,10,0);
    else
        [exp_cor,mant_cor]=coder.customfloat.helpers.appendMantissaAndCorrectExponent(cfType,aExponent,aMantissa);


        [exp_norm,mant_norm]=trig_Normalize_Exp_Mant(cfType,exp_cor,mant_cor);


        [angle,left_idx,flag]=binary_search(cfType,exp_norm,mant_norm);


        approx=linear_approx(angle,AtanApproxSlopeTable(left_idx),AtanApproxInterceptTable(left_idx),PiOverTwo,flag);


        [Exponent,Mantissa]=Normalize_answer(cfType,approx);


        [Exponent,Mantissa]=coder.customfloat.helpers.rounding(Exponent,Mantissa,true);
    end

    Sign=aSign;
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















function[angle,left_idx,flag]=binary_search(cfType,exp_norm,mant_norm)
    if mant_norm==1&&exp_norm==cfType.ExponentBias
        angle=fi(1,0,15,14);
        left_idx=fi(16,0,5,0);
        flag=false;
    else
        flag=false;
        if exp_norm>cfType.ExponentBias-1
            flag=true;

            [exp_norm,mant_norm]=reciprocal(cfType,exp_norm,mant_norm);
        end
        angle=fi(mant_norm,0,15,14);
        angle=coder.customfloat.helpers.safe_bitsra(angle,cast(15,'like',exp_norm)-exp_norm);


        tmp_idx=bitsliceget(angle,angle.WordLength-1,angle.WordLength-4);
        left_idx=fi(tmp_idx+fi(1,0,4,0),0,5,0);
    end
end















function approx=linear_approx(angle,slope,intercept,PiOverTwo,flag)
    if flag
        approx=fi(PiOverTwo-(slope*angle+intercept),0,18,17);
    else
        approx=fi(slope*angle+intercept,0,18,17);
    end

end










function[Exponent,Mantissa]=Normalize_answer(cfType,approx)
    if approx==0
        Mantissa=fi(0,0,cfType.MantissaLength+1,0);
        Exponent=fi(0,0,cfType.ExponentLength,0);
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
            Exponent=fi(15-int8(bit_shift_length),1,cfType.ExponentLength+1,0);
            Mantissa=coder.customfloat.helpers.safe_bitsll(approx,bit_shift_length);
            if Exponent<=0
                Mantissa=bitsrl(Mantissa,abs(Exponent)+cast(1,'like',Exponent));
                Exponent(:)=0;
            end
        end
        Mantissa=bitsliceget(Mantissa,Mantissa.WordLength-1,Mantissa.WordLength-1-cfType.MantissaLength);
        Exponent=fi(Exponent,0,cfType.ExponentLength,0);
    end
end













function[exp_norm,mant_norm]=reciprocal(cfType,exp_a_norm,mant_a_norm)
    mant_a_norm=bitconcat(fi(0,0,2,0),mant_a_norm);
    mant_a_norm=reinterpretcast(mant_a_norm,numerictype(1,mant_a_norm.WordLength,0));
    [mant_1_norm,shifted]=recip_Get_Divident(cfType,mant_a_norm);
    [exp_norm,shift_length]=recip_Extract_Exp_Denormals(cfType,exp_a_norm,shifted);
    Q=recip_Long_Div(mant_1_norm,mant_a_norm,cfType.MantissaLength);
    mant_norm=recip_Normalize_Denormals(Q,shift_length);
end

function[mant_1_norm,shifted]=recip_Get_Divident(cfType,mant_a)
    mant_1_norm=fi(0,1,cfType.MantissaLength+3,0);

    if(bitsliceget(mant_a,cfType.MantissaLength,1)~=0)
        shifted=true;
        mant_1_norm(:)=bitset(mant_1_norm,cfType.MantissaLength+2);
    else
        shifted=false;
        mant_1_norm(:)=bitset(mant_1_norm,cfType.MantissaLength+1);
    end
end

function[exp_c,shift_length]=recip_Extract_Exp_Denormals(cfType,exp_a_norm,shifted)
    if(shifted)
        exp_tmp=fi(cast(2*cfType.ExponentBias-1,'like',exp_a_norm)-exp_a_norm,1,exp_a_norm.WordLength,0);
    else
        exp_tmp=fi(cast(2*cfType.ExponentBias,'like',exp_a_norm)-exp_a_norm,1,exp_a_norm.WordLength,0);
    end

    if(exp_tmp<1)

        exp_c=fi(0,0,cfType.ExponentLength,0);

        if(exp_tmp>-(cfType.MantissaLength+1))
            shift_length=uint8(1-int8(exp_tmp));
        else
            shift_length=uint8(cfType.MantissaLength+2);
        end
    else

        shift_length=uint8(0);
        exp_c=fi(exp_tmp,0,cfType.ExponentLength,0);
    end
    exp_c=fi(bitconcat(fi(0,0,1,0),exp_c),1,6,0);
end

function Q=recip_Long_Div(mant_a_norm,mant_b_norm,ML)
    Q=fi(0,0,ML+2,0);

    R=mant_a_norm;

    for ii=coder.unroll((ML+2):-1:1)
        [Q,R]=recip_Long_Div_get_digit(Q,R,mant_b_norm,ii);
    end
end

function[Q,R]=recip_Long_Div_get_digit(Q,R,mant_b_norm,ii)
    tmp=cast(R-mant_b_norm,'like',R);
    if(tmp>=0)
        Q(:)=bitset(Q,ii,1);
        R=tmp;
    end
    R(:)=bitsll(R,1);
end

function mant=recip_Normalize_Denormals(Q,shift_length)
    if(shift_length>0)
        if(shift_length<Q.WordLength)
            Q(:)=bitsrl(Q,shift_length);
        else
            Q(:)=0;
        end
    end

    mant=bitsliceget(Q,Q.WordLength-1,2);
    mant=bitconcat(fi(1,0,1,0),mant);
    mant=reinterpretcast(mant,numerictype(0,mant.WordLength,mant.WordLength-1));
end
