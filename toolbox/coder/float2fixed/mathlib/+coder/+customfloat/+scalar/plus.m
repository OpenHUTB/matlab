%#codegen






function[Sign,Exponent,Mantissa]=plus(cfType,aSign,aExponent,aMantissa,bSign,bExponent,bMantissa,denormal)

    coder.allowpcode('plain');

    [aExponent,aMantissa]=coder.customfloat.helpers.checkDenormal(cfType,aExponent,aMantissa,denormal);
    [bExponent,bMantissa]=coder.customfloat.helpers.checkDenormal(cfType,bExponent,bMantissa,denormal);

    [aSign,aExponent,aMantissa,bSign,bExponent,bMantissa]=coder.customfloat.helpers.getAbsLarger(aSign,aExponent,aMantissa,bSign,bExponent,bMantissa);

    Sign=aSign;

    opp_Sign=bitxor(aSign,bSign);

    if(aExponent==cfType.Exponent_Inf_or_NaN)

        [Exponent,Mantissa]=plus_Inf_or_NaN(cfType,opp_Sign,aExponent,aMantissa,bExponent);
    else

        [exp_a_cor,mant_a_cor]=coder.customfloat.helpers.appendMantissaAndCorrectExponent(cfType,aExponent,aMantissa);
        [exp_b_cor,mant_b_cor]=coder.customfloat.helpers.appendMantissaAndCorrectExponent(cfType,bExponent,bMantissa);

        [Exponent,Mantissa]=plus_Main(cfType,exp_a_cor,mant_a_cor,exp_b_cor,mant_b_cor,opp_Sign,denormal);


        if(Exponent==0)&&(Mantissa==0)
            Sign(:)=(aSign==1)&&(bSign==1);
        end

    end


end

function[Exponent,Mantissa]=plus_Main(cfType,exp_a_cor,mant_a_cor,exp_b_cor,mant_b_cor,opp_Sign,denormal)









    [mant_a_ext,mant_b_ext]=plus_Append_Mantissas(cfType,mant_a_cor,mant_b_cor);





    [mant_b_shifted,sticky]=plus_Align_Mantissa(exp_a_cor,exp_b_cor,mant_b_ext,opp_Sign);


    Sum=plus_Add_Mantissas(cfType,mant_a_ext,mant_b_shifted);


    [exp_norm,mant_norm,sticky]=plus_Normalize(cfType,exp_a_cor,Sum,sticky,denormal);


    if(denormal)
        [Exponent,Mantissa]=coder.customfloat.helpers.rounding(exp_norm,mant_norm,sticky);
    else
        [Exponent,Mantissa]=coder.customfloat.helpers.rounding_normals(exp_norm,mant_norm,sticky);
    end
end

function[mant_b_shifted,sticky]=plus_Align_Mantissa(exp_a_cor,exp_b_cor,mant_b_ext,opp_Sign)
    if(opp_Sign)
        mant_b_ext(:)=-mant_b_ext;
    end

    shift_length=storedInteger(exp_a_cor)-storedInteger(exp_b_cor);

    if(shift_length<2)
        sticky=false;
    else
        if(shift_length>=mant_b_ext.WordLength)
            sticky=(mant_b_ext>0);
        else
            sticky=(bitsll(mant_b_ext,mant_b_ext.WordLength-shift_length)~=0);
        end
    end

    mant_b_shifted=coder.customfloat.helpers.safe_bitsra(mant_b_ext,shift_length);
end

function Sum=plus_Add_Mantissas(cfType,mant_a_ext,mant_b_shifted)
    FL=cfType.MantissaLength+4;

    Sum=fi(mant_a_ext+mant_b_shifted,0,FL,0);

end


function[exp,mant]=plus_Inf_or_NaN(cfType,opp_signs,exp_a,mant_a,exp_b)
















    exp=exp_a;
    mant=mant_a;


    if(mant_a~=0)||(opp_signs&&(exp_b==cfType.Exponent_Inf_or_NaN))
        mant=bitset(mant,mant.WordLength,1);
    end
end




function[mant_a_ext,mant_b_ext]=plus_Append_Mantissas(cfType,mant_a,mant_b)
    FL=2+(1+cfType.MantissaLength)+2;

    mant_a_ext=reinterpretcast(bitconcat(fi(0,0,2,0),mant_a,fi(0,0,2,0)),numerictype(1,FL,0));
    mant_b_ext=reinterpretcast(bitconcat(fi(0,0,2,0),mant_b,fi(0,0,2,0)),numerictype(1,FL,0));
end

function[exp_norm,mant_norm,sticky]=plus_Normalize_Denormals(cfType,exp_a_cor,Sum,sticky)
    if bitget(Sum,Sum.WordLength)
        exp_norm=fi(exp_a_cor+cast(1,'like',exp_a_cor),0,cfType.ExponentLength,0);
        sticky=sticky||bitget(Sum,1);
        Sum(:)=bitsrl(Sum,1);
    elseif bitget(Sum,Sum.WordLength-1)
        exp_norm=exp_a_cor;
    elseif(Sum==0)
        exp_norm=fi(0,0,cfType.ExponentLength,0);
    else
        pos=coder.customfloat.helpers.findFirst1(bitsliceget(Sum,Sum.WordLength-2,1));
        shift_length=uint8(cfType.MantissaLength+3)-pos;
        if(shift_length>=exp_a_cor)
            shift_length(:)=exp_a_cor-1;
            exp_norm=fi(1,0,cfType.ExponentLength,0);
        else
            exp_norm=cast(exp_a_cor-shift_length,'like',exp_a_cor);
        end

        Sum(:)=bitsll(Sum,shift_length);
    end

    if(exp_norm==cfType.Exponent_Inf_or_NaN)
        Sum(:)=0;
    elseif(bitget(Sum,Sum.WordLength-1)==0)
        exp_norm=fi(0,0,cfType.ExponentLength,0);
    end

    sticky=(sticky||bitget(Sum,1));
    mant_norm=bitsliceget(Sum,cfType.MantissaLength+2,2);
end

function[exp_norm,mant_norm,sticky]=plus_Normalize_Normals(cfType,exp_a_cor,Sum,sticky)
    if bitget(Sum,Sum.WordLength)
        exp_norm=fi(exp_a_cor+1,0,cfType.ExponentLength,0);
        sticky=sticky||bitget(Sum,1);
        Sum(:)=bitsrl(Sum,1);
    elseif bitget(Sum,Sum.WordLength-1)
        exp_norm=exp_a_cor;
    elseif(Sum==0)
        exp_norm=fi(0,0,cfType.ExponentLength,0);
    else
        pos=coder.customfloat.helpers.FindFirst1(bitsliceget(Sum,Sum.WordLength-2,1));
        shift_length=uint8(cfType.MantissaLength+3)-pos;
        if(shift_length>=exp_a_cor)
            shift_length(:)=exp_a_cor-1;
            exp_norm=fi(1,0,cfType.ExponentLength,0);
        else
            exp_norm=cast(exp_a_cor-shift_length,'like',exp_a_cor);
        end

        Sum(:)=bitsll(Sum,shift_length);
    end

    if(exp_norm==cfType.Exponent_Inf_or_NaN)
        Sum(:)=0;
    elseif(bitget(Sum,Sum.WordLength-1)==0)
        if bitget(Sum,Sum.WordLength-2)
            exp_norm=fi(1,0,cfType.ExponentLength,0);
        else
            exp_norm=fi(0,0,cfType.ExponentLength,0);
        end

        Sum(:)=0;
    end

    sticky=(sticky||bitget(Sum,1));
    mant_norm=bitsliceget(Sum,cfType.MantissaLength+2,2);
end


function[exp_norm,mant_norm,sticky]=plus_Normalize(cfType,exp_a_cor,Sum,sticky,denormal)
    if(denormal)
        [exp_norm,mant_norm,sticky]=plus_Normalize_Denormals(cfType,exp_a_cor,Sum,sticky);
    else
        [exp_norm,mant_norm,sticky]=plus_Normalize_Normals(cfType,exp_a_cor,Sum,sticky);
    end
end
