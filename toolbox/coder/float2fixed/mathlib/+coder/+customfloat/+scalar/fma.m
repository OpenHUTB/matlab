%#codegen










function[Sign,Exponent,Mantissa]=fma(cfType,aSign,aExponent,aMantissa,bSign,bExponent,bMantissa,...
    cSign,cExponent,cMantissa,denormal)
    coder.allowpcode('plain');


    [aExponent,aMantissa]=coder.customfloat.helpers.checkDenormal(cfType,aExponent,aMantissa,denormal);
    [bExponent,bMantissa]=coder.customfloat.helpers.checkDenormal(cfType,bExponent,bMantissa,denormal);
    [cExponent,cMantissa]=coder.customfloat.helpers.checkDenormal(cfType,cExponent,cMantissa,denormal);


    aExpInforNaN=(aExponent==cfType.Exponent_Inf_or_NaN);
    bExpInforNaN=(bExponent==cfType.Exponent_Inf_or_NaN);
    cExpInforNaN=(cExponent==cfType.Exponent_Inf_or_NaN);
    aMantZero=(aMantissa==0);
    bMantZero=(bMantissa==0);
    cMantZero=(cMantissa==0);
    aIsZero=((aExponent==0)&&(aMantZero));
    bIsZero=((bExponent==0)&&(bMantZero));
    cIsZero=((cExponent==0)&&(cMantZero));


    if(aExpInforNaN||bExpInforNaN||cExpInforNaN)
        [Sign,Exponent,Mantissa]=fma_Inf_or_NaN(cfType,aSign,aMantissa,...
        bSign,bMantissa,...
        cSign,cMantissa,...
        aExpInforNaN,aMantZero,aIsZero,...
        bExpInforNaN,bMantZero,bIsZero,...
        cExpInforNaN,cMantZero);

    elseif(aIsZero)||(bIsZero)
        if cIsZero
            Sign=bitand(bitxor(aSign,bSign),cSign);
        else
            Sign=cSign;
        end
        Exponent=cExponent;
        Mantissa=cMantissa;


    else

        [exp_a_cor,mant_a_cor]=coder.customfloat.helpers.appendMantissaAndCorrectExponent(cfType,aExponent,aMantissa);
        [exp_b_cor,mant_b_cor]=coder.customfloat.helpers.appendMantissaAndCorrectExponent(cfType,bExponent,bMantissa);
        [exp_c_cor,mant_c_cor]=coder.customfloat.helpers.appendMantissaAndCorrectExponent(cfType,cExponent,cMantissa);

        [Sign,Exponent,Mantissa]=fma_Main(cfType,aSign,exp_a_cor,mant_a_cor,bSign,exp_b_cor,mant_b_cor,cSign,exp_c_cor,mant_c_cor,denormal);
    end
end


function[Sign,Exponent,Mantissa]=fma_Inf_or_NaN(cfType,aSign,aMantissa,...
    bSign,bMantissa,...
    cSign,cMantissa,...
    aExpInforNaN,aMantZero,aIsZero,...
    bExpInforNaN,bMantZero,bIsZero,...
    cExpInforNaN,cMantZero)

    Exponent=cfType.Exponent_Inf_or_NaN;
    Sign=cSign;
    if(aExpInforNaN||bExpInforNaN)
        pSign=bitxor(aSign,bSign);
        [pSign,~,pMantissa]=times_Inf_or_NaN(cfType,pSign,aSign,aMantissa,bSign,bMantissa,...
        aExpInforNaN,aMantZero,aIsZero,...
        bExpInforNaN,bMantZero,bIsZero);
        pMantZero=(pMantissa==0);
        if(~pMantZero)
            Mantissa=cfType.Mantissa_NaN;
        else
            if(cExpInforNaN)
                if(~cMantZero)
                    Mantissa=cfType.Mantissa_NaN;
                else
                    opp_Sign=bitxor(cSign,pSign);
                    if(opp_Sign)
                        Mantissa=cfType.Mantissa_NaN;
                    else
                        Mantissa=cMantissa;
                    end
                end
            else
                Mantissa=pMantissa;
                Sign=pSign;
            end
        end
    else
        Mantissa=cMantissa;
    end
end


function[Sign,Exponent,Mantissa]=times_Inf_or_NaN(cfType,Sign,aSign,aMantissa,...
    bSign,bMantissa,...
    aExpInforNaN,aMantZero,aIsZero,...
    bExpInforNaN,bMantZero,bIsZero)
    Exponent=cfType.Exponent_Inf_or_NaN;

    if(aExpInforNaN)
        Mantissa=aMantissa;
        if(~aMantZero)
            Sign=aSign;
        elseif(bIsZero||((~bMantZero)&&bExpInforNaN))
            Mantissa=cfType.Mantissa_NaN;
        end
    else
        Mantissa=bMantissa;
        if(~bMantZero)
            Sign=bSign;
        elseif(aIsZero||((~aMantZero)&&aExpInforNaN))
            Mantissa=cfType.Mantissa_NaN;
        end
    end
end













function[Sign,Exponent,Mantissa]=fma_Main(cfType,aSign,exp_a_cor,mant_a_cor,bSign,exp_b_cor,mant_b_cor,cSign,exp_c_cor,mant_c_cor,denormal)


    [exp_a_norm,mant_a_norm]=fma_Normalize_Exp_Mant(cfType,exp_a_cor,mant_a_cor,denormal);
    [exp_b_norm,mant_b_norm]=fma_Normalize_Exp_Mant(cfType,exp_b_cor,mant_b_cor,denormal);
    [exp_c_norm,mant_c_norm]=fma_Normalize_Exp_Mant(cfType,exp_c_cor,mant_c_cor,denormal);


    pSign=bitxor(aSign,bSign);
    prod_exp=cast(exp_a_norm+exp_b_norm,'like',exp_a_norm);
    [pExponent,pMantissa]=fma_times_Product(cfType,mant_a_norm,mant_b_norm,prod_exp);


    if(mant_c_cor~=0)

        mant_c_ext=reinterpretcast(bitconcat(mant_c_norm,fi(0,0,1+cfType.MantissaLength,0)),numerictype(0,2*(1+cfType.MantissaLength),0));
        mant_c_ext=reinterpretcast(mant_c_ext,numerictype(0,mant_c_ext.WordLength,mant_c_ext.WordLength-1));
        [lSign,lExponent,lMantissa,sSign,sExponent,sMantissa]=fma_getAbsLarger(pSign,pExponent,pMantissa,cSign,exp_c_norm,mant_c_ext);
        Sign=lSign;


        [mant_l_ext,mant_s_ext]=fma_Append_Mantissas(lMantissa,sMantissa);


        opp_Sign=bitxor(lSign,sSign);
        [mant_s_shifted,sticky]=fma_Align_Mantissa(lExponent,sExponent,mant_s_ext,opp_Sign);


        Sum=fma_Add_Mantissas(mant_l_ext,mant_s_shifted);
    else
        Sign=pSign;
        Sum=reinterpretcast(bitconcat(fi(0,0,1,0),pMantissa,fi(0,0,1,0)),numerictype(0,2*(2+cfType.MantissaLength),0));
        lExponent=pExponent;
        sticky=false;
    end

    if(Sum==0)
        Exponent=fi(0,0,cfType.ExponentLength,0);
        Mantissa=fi(0,0,cfType.MantissaLength,0);

        Sign(:)=(pSign==1)&&(cSign==1);


    else
        [exp_norm,mant_norm,sticky]=fma_Normalize(cfType,lExponent,Sum,sticky,denormal);


        if(denormal)
            [Exponent,Mantissa]=coder.customfloat.helpers.rounding(exp_norm,mant_norm,sticky);
        else
            [Exponent,Mantissa]=coder.customfloat.helpers.rounding_normals(exp_norm,mant_norm,sticky);
        end
    end
end













function[exp_norm,mant_norm]=fma_Normalize_Exp_Mant(cfType,exp_cor,mant_cor,denormal)
    if(denormal)
        [exp_norm,mant_norm]=fma_Normalize_Exp_Mant_Denormal(cfType,exp_cor,mant_cor);
    else
        [exp_norm,mant_norm]=fma_Normalize_Exp_Mant_Normal(cfType,exp_cor,mant_cor);
    end
end

function[exp_norm,mant_norm]=fma_Normalize_Exp_Mant_Denormal(cfType,exp_a,mant_a)
    if(bitget(mant_a,mant_a.WordLength)==0)
        ia=int8(mant_a.WordLength)-int8(coder.customfloat.helpers.findFirst1(mant_a));
        exp_norm=fi(1-ia,1,cfType.ExponentLength+3,0);
        mant_a(:)=coder.customfloat.helpers.safe_bitsll(mant_a,ia);
    else
        exp_norm=fi(exp_a,1,cfType.ExponentLength+3,0);
    end
    mant_norm=reinterpretcast(mant_a,numerictype(0,cfType.MantissaLength+1,cfType.MantissaLength));
end

function[exp_norm,mant_norm]=fma_Normalize_Exp_Mant_Normal(cfType,exp_a,mant_a)
    exp_norm=fi(exp_a,1,cfType.ExponentLength+3,0);
    mant_norm=reinterpretcast(mant_a,numerictype(0,cfType.MantissaLength+1,cfType.MantissaLength));
end











function[exp_out,mant_out]=fma_times_Product(cfType,mant_a_norm,mant_b_norm,exp_sum)
    mant_ext=mant_a_norm*mant_b_norm;
    if bitget(mant_ext,mant_ext.WordLength)
        exp_out=cast(exp_sum-cfType.ExponentBias+cast(1,'like',exp_sum),'like',exp_sum);
        mant_out=reinterpretcast(mant_ext,numerictype(0,mant_ext.WordLength,mant_ext.WordLength-1));
    else
        exp_out=cast(exp_sum-cfType.ExponentBias,'like',exp_sum);
        mant_out=reinterpretcast(bitsll(mant_ext,1),numerictype(0,mant_ext.WordLength,mant_ext.WordLength-1));
    end
end




function[lSign,lExponent,lMantissa,sSign,sExponent,sMantissa]=fma_getAbsLarger(aSign,aExponent,aMantissa,bSign,bExponent,bMantissa)
    if(aExponent>bExponent)||((aExponent==bExponent)&&(aMantissa>bMantissa))
        lSign=aSign;
        lExponent=aExponent;
        lMantissa=aMantissa;
        sSign=bSign;
        sExponent=bExponent;
        sMantissa=bMantissa;
    else
        lSign=bSign;
        lExponent=bExponent;
        lMantissa=bMantissa;
        sSign=aSign;
        sExponent=aExponent;
        sMantissa=aMantissa;
    end
end


function[mant_a_ext,mant_b_ext]=fma_Append_Mantissas(mant_a,mant_b)
    FL=3+mant_a.WordLength;
    mant_a_ext=reinterpretcast(bitconcat(fi(0,0,2,0),mant_a,fi(0,0,1,0)),numerictype(1,FL,0));
    mant_b_ext=reinterpretcast(bitconcat(fi(0,0,2,0),mant_b,fi(0,0,1,0)),numerictype(1,FL,0));
end












function[mant_b_shifted,sticky]=fma_Align_Mantissa(exp_a_cor,exp_b_cor,mant_b_ext,opp_Sign)
    if(opp_Sign)
        mant_b_ext(:)=-mant_b_ext;
    end
    shift_length=storedInteger(exp_a_cor)-storedInteger(exp_b_cor);
    if(shift_length<2)
        sticky=false;
    else
        if(shift_length>=mant_b_ext.WordLength)
            sticky=(mant_b_ext~=0);
        else
            sticky=(bitsll(mant_b_ext,mant_b_ext.WordLength-shift_length)~=0);
        end
    end
    mant_b_shifted=coder.customfloat.helpers.safe_bitsra(mant_b_ext,shift_length);
end

function Sum=fma_Add_Mantissas(mant_a_ext,mant_b_shifted)
    FL=mant_a_ext.WordLength-1;
    Sum=fi(mant_a_ext+mant_b_shifted,0,FL,0);
end












function[exp_norm,mant_norm,sticky]=fma_Normalize(cfType,exp_a_cor,Sum,sticky,denormal)
    if(denormal)
        [exp_norm,mant_norm,sticky]=fma_Normalize_Denormals(cfType,exp_a_cor,Sum,sticky);
    else
        [exp_norm,mant_norm,sticky]=fma_Normalize_Normals(cfType,exp_a_cor,Sum,sticky);
    end
end

function[exp_norm,mant_norm,sticky]=fma_Normalize_Denormals(cfType,exp_a_cor,Sum,sticky)
    pos=coder.customfloat.helpers.findFirst1(Sum);
    shift_length_1=Sum.WordLength-pos;
    Sum(:)=bitsll(Sum,shift_length_1);
    exp_norm=fi(exp_a_cor-shift_length_1+1,1,cfType.ExponentLength+3,0);
    if exp_norm<=0
        shift_length_2=1-exp_norm;
        if shift_length_2>=Sum.WordLength
            sticky2=(Sum~=0);
            Sum=cast(0,'like',Sum);
        else
            sticky2=(bitsll(Sum,Sum.WordLength-shift_length_2)~=0);
            Sum(:)=bitsrl(Sum,shift_length_2);
        end
        sticky=(sticky||sticky2);
        exp_norm=fi(0,0,cfType.ExponentLength,0);
    else
        exp_norm=fi(exp_norm,0,cfType.ExponentLength,0);
    end

    if(exp_norm==cfType.Exponent_Inf_or_NaN)
        Sum(:)=0;
    end
    sticky=(sticky||(bitsliceget(Sum,Sum.WordLength-2-cfType.MantissaLength,1)~=0));
    mant_norm=bitsliceget(Sum,Sum.WordLength-1,Sum.WordLength-1-cfType.MantissaLength);
end




function[exp_norm,mant_norm,sticky]=fma_Normalize_Normals(cfType,exp_a_cor,Sum,sticky)

    pos=coder.customfloat.helpers.findFirst1(Sum);
    shift_length_1=Sum.WordLength-pos;
    Sum(:)=bitsll(Sum,shift_length_1);
    exp_norm=fi(exp_a_cor-shift_length_1+1,1,cfType.ExponentLength+3,0);


    if exp_norm<=0
        shift_length_2=1-exp_norm;
        if shift_length_2>=Sum.WordLength
            sticky2=(Sum~=0);
            Sum=cast(0,'like',Sum);
        else
            sticky2=(bitsll(Sum,Sum.WordLength-shift_length_2)~=0);
            Sum(:)=bitsrl(Sum,shift_length_2);
        end
        sticky=(sticky||sticky2);
        exp_norm=fi(0,0,cfType.ExponentLength,0);


    else
        exp_norm=fi(exp_norm,0,cfType.ExponentLength,0);
    end

    if(exp_norm==cfType.Exponent_Inf_or_NaN)
        Sum(:)=0;
    end
    sticky=(sticky||(bitsliceget(Sum,Sum.WordLength-2-cfType.MantissaLength,1)~=0));
    mant_norm=bitsliceget(Sum,Sum.WordLength-1,Sum.WordLength-1-cfType.MantissaLength);
end