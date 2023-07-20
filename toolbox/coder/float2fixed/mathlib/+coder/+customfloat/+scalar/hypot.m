%#codegen






function[Sign,Exponent,Mantissa]=hypot(cfType,aSign,aExponent,aMantissa,bSign,bExponent,bMantissa,HypotScalingFactor)
    coder.allowpcode('plain');


    if((aExponent==cfType.Exponent_Inf_or_NaN)||(bExponent==cfType.Exponent_Inf_or_NaN))
        [Sign,Exponent,Mantissa]=hypot_Inf_or_NaN(cfType,aSign,aExponent,aMantissa,bSign,bExponent,bMantissa);
    else
        Sign=fi(0,0,1,0);

        [exp_a_cor,mant_a_cor]=coder.customfloat.helpers.appendMantissaAndCorrectExponent(cfType,aExponent,aMantissa);
        [exp_b_cor,mant_b_cor]=coder.customfloat.helpers.appendMantissaAndCorrectExponent(cfType,bExponent,bMantissa);

        [Exponent,Mantissa]=hypot_Main(cfType,exp_a_cor,mant_a_cor,exp_b_cor,mant_b_cor,HypotScalingFactor);
    end
end

function[Exponent,Mantissa]=hypot_Main(cfType,exp_a_cor,mant_a_cor,exp_b_cor,mant_b_cor,HypotScalingFactor)

    mant_a_norm=reinterpretcast(bitconcat(fi(0,0,3,0),mant_a_cor,fi(0,0,cfType.HypotIntermediatePrec-cfType.MantissaLength,0)),...
    numerictype(1,cfType.HypotIntermediatePrec+4,cfType.HypotIntermediatePrec));
    mant_b_norm=reinterpretcast(bitconcat(fi(0,0,3,0),mant_b_cor,fi(0,0,cfType.HypotIntermediatePrec-cfType.MantissaLength,0)),...
    numerictype(1,cfType.HypotIntermediatePrec+4,cfType.HypotIntermediatePrec));


    [exp_out,mant_a_aligned,mant_b_aligned]=hypot_Align_Mantissas(cfType,exp_a_cor,mant_a_norm,exp_b_cor,mant_b_norm);


    y_out=hypot_CORDIC_Rotate(cfType,mant_a_aligned,mant_b_aligned);

    mant_scaled=hypot_Post_Scaling(y_out,HypotScalingFactor);

    [exp_out,mant_out,sticky]=hypot_Normalize_Answer(cfType,exp_out,mant_scaled);


    [Exponent,Mantissa]=coder.customfloat.helpers.rounding(exp_out,mant_out,sticky);

    if(Exponent==cfType.Exponent_Inf_or_NaN)
        Mantissa(:)=0;
    end
end


function[exp_out,mant_out,sticky]=hypot_Normalize_Answer(cfType,exp_out,mant_scaled)
    if(bitget(mant_scaled,mant_scaled.FractionLength+3))
        exp_out(:)=exp_out+cast(1,'like',exp_out);
    elseif(bitget(mant_scaled,mant_scaled.FractionLength+2))
        mant_scaled(:)=bitsll(mant_scaled,1);
    else
        exp_out(:)=exp_out-cast(1,'like',exp_out);
        if(exp_out~=0)
            mant_scaled(:)=bitsll(mant_scaled,2);
        else
            mant_scaled(:)=bitsll(mant_scaled,1);
        end
    end

    mant_out=bitsliceget(mant_scaled,mant_scaled.FractionLength+2,mant_scaled.FractionLength+2-cfType.MantissaLength);
    sticky=(bitsliceget(mant_scaled,mant_scaled.FractionLength+1-cfType.MantissaLength,1)~=0);
end


function mant_scaled=hypot_Post_Scaling(y_out,HypotScalingFactor)
    mant_scaled=y_out*HypotScalingFactor;
end



function[exp_out,mant_a_aligned,mant_b_aligned]=hypot_Align_Mantissas(cfType,exp_a_cor,mant_a_norm,exp_b_cor,mant_b_norm)
    exp_a=reinterpretcast(bitconcat(fi(0,0,2,0),exp_a_cor),numerictype(1,cfType.ExponentLength+2,0));
    exp_b=reinterpretcast(bitconcat(fi(0,0,2,0),exp_b_cor),numerictype(1,cfType.ExponentLength+2,0));
    exp_diff=fi(exp_a-exp_b,1,cfType.ExponentLength+2,0);

    mant_a_aligned=mant_a_norm;
    mant_b_aligned=mant_b_norm;

    if(bitget(exp_diff,exp_diff.WordLength))
        exp_out=exp_b_cor;
        mant_a_aligned(:)=coder.customfloat.helpers.safe_bitsra(mant_a_norm,-exp_diff);
    else
        exp_out=exp_a_cor;
        mant_b_aligned(:)=coder.customfloat.helpers.safe_bitsra(mant_b_norm,exp_diff);
    end
end


function y_out=hypot_CORDIC_Rotate(cfType,mant_a_aligned,mant_b_aligned)
    for ii=0:1:cfType.MantissaLength
        [mant_a_aligned,mant_b_aligned]=hypot_CORDIC_MicroRotate(mant_a_aligned,mant_b_aligned,ii);
    end
    y_out=reinterpretcast(bitsliceget(mant_a_aligned,mant_a_aligned.WordLength-1,1),...
    numerictype(0,mant_a_aligned.WordLength-1,mant_a_aligned.FractionLength));
end

function[mant_a_out,mant_b_out]=hypot_CORDIC_MicroRotate(mant_a_aligned,mant_b_aligned,ii)
    mant_a_out=mant_a_aligned;
    mant_b_out=mant_b_aligned;

    if bitget(mant_b_aligned,mant_b_aligned.WordLength)
        mant_a_out(:)=mant_a_aligned-bitsra(mant_b_aligned,ii);
        mant_b_out(:)=mant_b_aligned+bitsra(mant_a_aligned,ii);
    else
        mant_a_out(:)=mant_a_aligned+bitsra(mant_b_aligned,ii);
        mant_b_out(:)=mant_b_aligned-bitsra(mant_a_aligned,ii);
    end
end

function[Sign,Exponent,Mantissa]=hypot_Inf_or_NaN(cfType,aSign,aExponent,aMantissa,bSign,bExponent,bMantissa)
    Sign=fi(0,0,1,0);
    Exponent=cfType.Exponent_Inf_or_NaN;
    Mantissa=fi(0,0,cfType.MantissaLength,0);

    if((aExponent==cfType.Exponent_Inf_or_NaN)&&(aMantissa~=0))

        Sign=aSign;
        Mantissa=aMantissa;
    elseif((bExponent==cfType.Exponent_Inf_or_NaN)&&(bMantissa~=0))

        Sign=bSign;
        Mantissa=bMantissa;
    end
end
