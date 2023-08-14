%#codegen









function[Sign,Exponent,Mantissa]=atan2(cfType,aSign,aExponent,aMantissa,bSign,bExponent,bMantissa,PiExponent,PiMantissa,...
    PiOverTwoExponent,PiOverTwoMantissa,PiOverFourExponent,PiOverFourMantissa,ThreePiOverFourExponent,ThreePiOverFourMantissa,...
    PiOverTwo,Pi,AtanApproxSlopeTable,AtanApproxInterceptTable,denormal)

    coder.allowpcode('plain');

    if(aExponent==cfType.Exponent_Inf_or_NaN)||(bExponent==cfType.Exponent_Inf_or_NaN)

        [Sign,Exponent,Mantissa]=atan2_Inf_or_NaN(cfType,aSign,aExponent,aMantissa,bSign,bExponent,bMantissa,...
        PiExponent,PiMantissa,PiOverTwoExponent,PiOverTwoMantissa,PiOverFourExponent,PiOverFourMantissa,...
        ThreePiOverFourExponent,ThreePiOverFourMantissa);
    elseif(bExponent==0&&bMantissa==0)||((aExponent==0&&aMantissa==0))

        [Sign,Exponent,Mantissa]=atan2_zero(cfType,aSign,aExponent,aMantissa,bSign,bExponent,bMantissa,...
        PiExponent,PiMantissa,PiOverTwoExponent,PiOverTwoMantissa);
    else

        [Sign,Exponent,Mantissa]=atan2_Main(cfType,aSign,aExponent,aMantissa,bSign,bExponent,bMantissa,...
        PiOverTwo,Pi,AtanApproxSlopeTable,AtanApproxInterceptTable,denormal);
    end
end


function[Sign,Exponent,Mantissa]=atan2_Main(cfType,aSign,aExponent,aMantissa,bSign,bExponent,bMantissa,...
    PiOverTwo,Pi,AtanApproxSlopeTable,AtanApproxInterceptTable,denormal)
    flag=false;

    constWL=30;
    constML=27;
    oSign=bitxor(aSign,bSign);
    if(aExponent<bExponent)||(aExponent==bExponent&&aMantissa<=bMantissa)

        divideInputExponent1=aExponent;
        divideInputMantissa1=aMantissa;
        divideInputExponent2=bExponent;
        divideInputMantissa2=bMantissa;

        addInputSign=oSign;
        if bSign
            if aSign
                const=-fi(Pi,1,constWL,constML);
                Sign=fi(1,0,1,0);
            else
                const=fi(Pi,1,constWL,constML);
                Sign=fi(0,0,1,0);
            end
        else
            const=fi(0,1,constWL,constML);
            Sign=oSign;
            flag=true;
        end
    else

        divideInputExponent1=bExponent;
        divideInputMantissa1=bMantissa;
        divideInputExponent2=aExponent;
        divideInputMantissa2=aMantissa;

        addInputSign=bitcmp(oSign);
        if aSign
            const=-fi(PiOverTwo,1,constWL,constML);
            Sign=fi(1,0,1,0);
        else
            const=fi(PiOverTwo,1,constWL,constML);
            Sign=fi(0,0,1,0);
        end
    end


    divideInputMantissa1_appended=bitconcat(divideInputMantissa1,fi(0,0,4,0));
    divideInputMantissa2_appended=bitconcat(divideInputMantissa2,fi(0,0,4,0));
    [~,qExponent,qMantissa]=coder.customfloat.scalar.rdivide(CustomFloatType(20,14),...
    aSign,divideInputExponent1,divideInputMantissa1_appended,...
    bSign,divideInputExponent2,divideInputMantissa2_appended,...
    denormal);










    [oExponent,oMantissa]=atan_Main(cfType,qExponent,qMantissa,AtanApproxSlopeTable,AtanApproxInterceptTable);

    addInputExponent=oExponent;
    addInputMantissa=oMantissa;
    [Exponent,Mantissa]=atan2_shift_and_add(cfType,addInputSign,addInputExponent,addInputMantissa,const,Sign,flag);
end


function[Exponent,Mantissa]=atan2_shift_and_add(cfType,addInputSign,addInputExponent,addInputMantissa,const,Sign,flag)
    if flag
        Exponent=addInputExponent;
        Mantissa=bitsliceget(addInputMantissa,addInputMantissa.WordLength,addInputMantissa.WordLength-cfType.MantissaLength);
    else
        [exp_addInput_cor,mant_addInput_cor]=coder.customfloat.helpers.appendMantissaAndCorrectExponent(cfType,...
        addInputExponent,addInputMantissa);
        shift_length=uint8(cast(15,'like',exp_addInput_cor)-exp_addInput_cor);
        real_value=coder.customfloat.helpers.safe_bitsra(mant_addInput_cor,shift_length);
        signed_real_value=reinterpretcast(bitconcat(fi(0,0,1,0),real_value),...
        numerictype(1,real_value.WordLength+1,15));

        if addInputSign
            signed_real_value(:)=-signed_real_value;
        end
        output_real_value=const+signed_real_value;
        if Sign
            output_real_value=-output_real_value;
        end

        output_real_value=fi(output_real_value,0,cfType.MantissaLength+24,cfType.MantissaLength+21);

        pos=coder.customfloat.helpers.findFirst1(output_real_value);
        frac_length=output_real_value.FractionLength;
        if pos>frac_length
            shift_length_1=pos-frac_length-1;
            Exponent=fi(15+shift_length_1,0,5,0);
        else
            shift_length_1=uint8(frac_length+1)-pos;
            Exponent=fi(15-shift_length_1,0,5,0);
        end
        Mantissa_shifted=coder.customfloat.helpers.safe_bitsll(output_real_value,output_real_value.WordLength-pos);
        Mantissa=bitsliceget(Mantissa_shifted,Mantissa_shifted.WordLength-1,Mantissa_shifted.WordLength-1-cfType.MantissaLength);
    end
    [Exponent,Mantissa]=coder.customfloat.helpers.rounding(Exponent,Mantissa,true);
end


function[Exponent,Mantissa]=atan_Main(cfType,aExponent,aMantissa,AtanApproxSlopeTable,AtanApproxInterceptTable)



    if(aExponent<10)||(aExponent==10&&aMantissa<7592)
        Exponent=aExponent;
        Mantissa=bitconcat(aMantissa,fi(0,0,1,0));


    elseif aExponent==11&&aMantissa==0
        Exponent=fi(10,0,5,0);
        Mantissa=fi(32682,0,15,0);
    elseif aExponent==12&&aMantissa==0
        Exponent=fi(11,0,5,0);
        Mantissa=fi(32429,0,15,0);
    elseif aExponent==12&&aMantissa==16
        Exponent=fi(11,0,5,0);
        Mantissa=fi(32492,0,15,0);
    elseif aExponent==12&&aMantissa==32
        Exponent=fi(11,0,5,0);
        Mantissa=fi(32555,0,15,0);
    else
        [exp_cor,mant_cor]=coder.customfloat.helpers.appendMantissaAndCorrectExponent(cfType,aExponent,aMantissa);


        [exp_norm,mant_norm]=trig_Normalize_Exp_Mant(cfType,exp_cor,mant_cor);


        [angle,left_idx]=binary_search(cfType,exp_norm,mant_norm);


        approx=linear_approx(angle,AtanApproxSlopeTable(left_idx),AtanApproxInterceptTable(left_idx));


        [Exponent,Mantissa]=Normalize_answer(cfType,approx);



    end
end


function[Sign,Exponent,Mantissa]=atan2_Inf_or_NaN(cfType,aSign,aExponent,aMantissa,bSign,bExponent,bMantissa,...
    PiExponent,PiMantissa,PiOverTwoExponent,PiOverTwoMantissa,PiOverFourExponent,PiOverFourMantissa,...
    ThreePiOverFourExponent,ThreePiOverFourMantissa)
    if aExponent==cfType.Exponent_Inf_or_NaN
        if aMantissa==0
            if bExponent~=cfType.Exponent_Inf_or_NaN
                Exponent=PiOverTwoExponent;
                Mantissa=PiOverTwoMantissa;
            elseif bMantissa==0
                if bSign
                    Exponent=ThreePiOverFourExponent;
                    Mantissa=ThreePiOverFourMantissa;
                else
                    Exponent=PiOverFourExponent;
                    Mantissa=PiOverFourMantissa;
                end
            else
                Exponent=cfType.Exponent_Inf_or_NaN;
                Mantissa=cfType.Mantissa_NaN;
            end
        else
            Exponent=cfType.Exponent_Inf_or_NaN;
            Mantissa=cfType.Mantissa_NaN;
        end
    elseif bMantissa==0
        if bSign
            Exponent=PiExponent;
            Mantissa=PiMantissa;
        else
            Exponent=fi(0,0,cfType.ExponentLength,0);
            Mantissa=fi(0,0,cfType.MantissaLength,0);
        end
    else
        Exponent=cfType.Exponent_Inf_or_NaN;
        Mantissa=cfType.Mantissa_NaN;
    end
    Sign=aSign;
end


function[Sign,Exponent,Mantissa]=atan2_zero(cfType,aSign,aExponent,aMantissa,bSign,bExponent,bMantissa,...
    PiExponent,PiMantissa,PiOverTwoExponent,PiOverTwoMantissa)

    if bExponent==0&&bMantissa==0

        if aExponent==0&&aMantissa==0
            Exponent=fi(0,0,cfType.ExponentLength,0);
            Mantissa=fi(0,0,cfType.MantissaLength,0);
            Sign=fi(0,0,1,0);
        else
            Exponent=PiOverTwoExponent;
            Mantissa=PiOverTwoMantissa;
            Sign=aSign;
        end
    else

        if bSign
            Exponent=PiExponent;
            Mantissa=PiMantissa;
        else
            Exponent=fi(0,0,cfType.ExponentLength,0);
            Mantissa=fi(0,0,cfType.MantissaLength,0);
        end
        Sign=aSign;

    end

end












function[qExponent,qMantissa]=atan2_divide(cfType,aExponent,aMantissa,bExponent,bMantissa,denormal)
    [aExponent,aMantissa]=coder.customfloat.helpers.checkDenormal(cfType,aExponent,aMantissa,denormal);
    [bExponent,bMantissa]=coder.customfloat.helpers.checkDenormal(cfType,bExponent,bMantissa,denormal);

    [exp_a_cor,mant_a_cor]=coder.customfloat.helpers.appendMantissaAndCorrectExponent(cfType,aExponent,aMantissa);
    [exp_b_cor,mant_b_cor]=coder.customfloat.helpers.appendMantissaAndCorrectExponent(cfType,bExponent,bMantissa);
    [qExponent,qMantissa]=rdivide_Normal_Long_Div(cfType,exp_a_cor,mant_a_cor,exp_b_cor,mant_b_cor,denormal);
end


function[exp_c,Q]=rdivide_Normal_Long_Div(cfType,exp_a,mant_a,exp_b,mant_b,denormal)



    [exp_a_norm,mant_a_norm,exp_b_norm,mant_b_norm]=rdivide_Normalize_Exp_Mant(cfType,exp_a,mant_a,exp_b,mant_b,denormal);





    exp_c=rdivide_Extract_Exp(cfType,exp_a_norm,exp_b_norm,denormal);





    Q=rdivide_Long_Div(mant_a_norm,mant_b_norm,cfType.MantissaLength);
end


function exp_c=rdivide_Extract_Exp(cfType,exp_a_norm,exp_b_norm,denormal)
    if(denormal)
        exp_c=rdivide_Extract_Exp_Denormals(cfType,exp_a_norm,exp_b_norm);
    else
        exp_c=rdivide_Extract_Exp_Normals(cfType,exp_a_norm,exp_b_norm);
    end
end

function exp_c=rdivide_Extract_Exp_Denormals(cfType,exp_a_norm,exp_b_norm)
    exp_tmp=fi(exp_a_norm-exp_b_norm+cast(cfType.ExponentBias,'like',exp_a_norm),1,exp_a_norm.WordLength,0);

    if(exp_tmp>=2*cfType.ExponentBias+1)

        exp_c=cfType.Exponent_Inf_or_NaN;
    elseif(exp_tmp<1)

        exp_c=fi(0,0,cfType.ExponentLength,0);
    else

        exp_c=fi(exp_tmp,0,cfType.ExponentLength,0);
    end
end

function exp_c=rdivide_Extract_Exp_Normals(cfType,exp_a_norm,exp_b_norm)
    exp_tmp=fi(exp_a_norm-exp_b_norm+cast(cfType.ExponentBias,'like',exp_a_norm),1,exp_a_norm.WordLength,0);

    if(exp_tmp>=2*cfType.ExponentBias+1)

        exp_c=cfType.Exponent_Inf_or_NaN;
    elseif(exp_tmp<1)

        exp_c=fi(0,0,cfType.ExponentLength,0);
    else

        exp_c=fi(exp_tmp,0,cfType.ExponentLength,0);
    end
end


function Q=rdivide_Long_Div(mant_a_norm,mant_b_norm,ML)

    Q=fi(0,0,ML+5,0);

    R=mant_a_norm;

    for ii=coder.unroll((ML+5):-1:1)
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


function[exp_a_norm,mant_a_norm,exp_b_norm,mant_b_norm]=rdivide_Normalize_Exp_Mant(cfType,exp_a,mant_a,exp_b,mant_b,denormal)
    if(denormal)
        [exp_a_norm,mant_a_norm,exp_b_norm,mant_b_norm]=rdivide_Normalize_Exp_Mant_Denormals(cfType,exp_a,mant_a,exp_b,mant_b);
    else
        [exp_a_norm,mant_a_norm,exp_b_norm,mant_b_norm]=rdivide_Normalize_Exp_Mant_Normals(cfType,exp_a,mant_a,exp_b,mant_b);
    end
end

function[exp_a_norm,mant_a_norm,exp_b_norm,mant_b_norm]=rdivide_Normalize_Exp_Mant_Denormals(cfType,exp_a,mant_a,exp_b,mant_b)



    if(bitget(mant_a,mant_a.WordLength)==0)
        ia=int8(mant_a.WordLength)-int8(coder.customfloat.helpers.findFirst1(mant_a));
        exp_a_norm=fi(1-ia,1,cfType.ExponentLength+2,0);
        mant_a_norm=reinterpretcast(bitconcat(fi(0,0,2,0),bitsll(mant_a,ia)),numerictype(1,cfType.MantissaLength+3,0));
    else
        exp_a_norm=fi(exp_a,1,cfType.ExponentLength+2,0);
        mant_a_norm=reinterpretcast(bitconcat(fi(0,0,2,0),mant_a),numerictype(1,cfType.MantissaLength+3,0));
    end

    if(bitget(mant_b,mant_b.WordLength)==0)
        ib=int8(mant_b.WordLength)-int8(coder.customfloat.helpers.findFirst1(mant_b));
        exp_b_norm=fi(1-ib,1,cfType.ExponentLength+2,0);
        mant_b_norm=reinterpretcast(bitconcat(fi(0,0,2,0),bitsll(mant_b,ib)),numerictype(1,cfType.MantissaLength+3,0));
    else
        exp_b_norm=fi(exp_b,1,cfType.ExponentLength+2,0);
        mant_b_norm=reinterpretcast(bitconcat(fi(0,0,2,0),mant_b),numerictype(1,cfType.MantissaLength+3,0));
    end

    if(mant_a_norm<mant_b_norm)
        exp_a_norm(:)=exp_a_norm-cast(1,'like',exp_a_norm);
        mant_a_norm(:)=bitsll(mant_a_norm,1);
    end
end

function[exp_a_norm,mant_a_norm,exp_b_norm,mant_b_norm]=rdivide_Normalize_Exp_Mant_Normals(cfType,exp_a,mant_a,exp_b,mant_b)




    exp_a_norm=fi(exp_a,1,cfType.ExponentLength+2,0);
    mant_a_norm=reinterpretcast(bitconcat(fi(0,0,2,0),mant_a),numerictype(1,cfType.MantissaLength+3,0));

    exp_b_norm=fi(exp_b,1,cfType.ExponentLength+2,0);
    mant_b_norm=reinterpretcast(bitconcat(fi(0,0,2,0),mant_b),numerictype(1,cfType.MantissaLength+3,0));

    if(mant_a_norm<mant_b_norm)
        exp_a_norm(:)=exp_a_norm-cast(1,'like',exp_a_norm);
        mant_a_norm(:)=bitsll(mant_a_norm,1);
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

    mant_norm=reinterpretcast(mant_a,numerictype(0,cfType.MantissaLength+5,cfType.MantissaLength+4));
end














function[angle,left_idx]=binary_search(cfType,exp_norm,mant_norm)
    if mant_norm==1&&exp_norm==cfType.ExponentBias

        angle=fi(1,0,38,37);
        left_idx=fi(16,0,5,0);
    else

        angle=fi(mant_norm,0,38,37);
        angle=coder.customfloat.helpers.safe_bitsra(angle,cast(15,'like',exp_norm)-exp_norm);


        tmp_idx=bitsliceget(angle,angle.WordLength-1,angle.WordLength-4);
        left_idx=fi(tmp_idx+fi(1,0,4,0),0,5,0);
    end
end














function approx=linear_approx(angle,slope,intercept)


    approx=fi(slope*angle+intercept,0,40,39);

end










function[Exponent,Mantissa]=Normalize_answer(cfType,approx)
    if approx==0

        Mantissa=fi(0,0,cfType.MantissaLength+5,0);
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

        Mantissa=bitsliceget(Mantissa,Mantissa.WordLength-1,Mantissa.WordLength-5-cfType.MantissaLength);
        Exponent=fi(Exponent,0,cfType.ExponentLength,0);
    end
end

