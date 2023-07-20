%#codegen



function outFixed=cf2fixed(cfType,aSign,aExponent,aMantissa,Signed,WordLength,FracLength,denormal)

    coder.allowpcode('plain');

    if(aExponent==cfType.Exponent_Inf_or_NaN)

        outFixed=cf2fixed_Inf_or_NaN(aSign,aMantissa,Signed,WordLength,FracLength);
    elseif((aExponent==0)&&(aMantissa==0))

        outFixed=fi(0,Signed,WordLength,FracLength);
    else

        [exp_cor,mant_cor]=coder.customfloat.helpers.appendMantissaAndCorrectExponent(cfType,aExponent,aMantissa);

        outFixed=cf2fixed_Main(cfType,aSign,exp_cor,mant_cor,Signed,WordLength,FracLength,denormal);
    end
end


function outFixed=cf2fixed_Main(cfType,aSign,exp_cor,mant_cor,Signed,WordLength,FracLength,denormal)
    outFixed=coder.nullcopy(fi(0,Signed,WordLength,FracLength));


    [exp_norm,mant_norm]=cf2fixed_Normalize_Exp_Mant(cfType,exp_cor,mant_cor,denormal);

    wl=int16(WordLength);
    fl=int16(FracLength);
    max_exp=int16(cfType.ExponentBias-1)+wl-fl-int16(Signed);


    if(wl>cfType.MantissaLength)
        mant_ext=reinterpretcast(bitconcat(fi(0,0,1,0),mant_norm,fi(0,0,wl-int16(cfType.MantissaLength),0)),...
        numerictype(0,wl+2,fl+1));
    elseif(wl<cfType.MantissaLength)
        mant_ext=reinterpretcast(bitconcat(fi(0,0,1,0),bitsliceget(mant_norm,mant_norm.WordLength,mant_norm.WordLength-wl)),...
        numerictype(0,wl+2,fl+1));
    else
        mant_ext=reinterpretcast(bitconcat(fi(0,0,1,0),mant_norm),numerictype(0,wl+2,fl+1));
    end

    saturate=false;

    if(exp_norm>max_exp)
        saturate=true;
    else

        shift_length=max_exp+int16(Signed)-exp_norm;

        mant_ext(:)=coder.customfloat.helpers.safe_bitsra(mant_ext,shift_length);


        mant_tmp=reinterpretcast(mant_ext,numerictype(0,wl+2,0));

        if(bitget(mant_tmp,1)~=0)
            mant_tmp(:)=mant_tmp+cast(2,'like',mant_tmp);
        end

        mant_rounded=reinterpretcast(bitsliceget(mant_tmp,wl+2,2),numerictype(0,wl+1,wl));

        if aSign
            if Signed

                if(mant_rounded~=0)
                    mant_rounded(:)=cast(1,'like',mant_rounded)-mant_rounded;
                    mant_rounded(:)=bitset(mant_rounded,wl);
                end
            else
                saturate=true;
            end
        else
            if Signed
                if(bitsliceget(mant_rounded,wl+1,wl)~=0)

                    saturate=true;
                end
            else
                if bitget(mant_rounded,wl+1)

                    saturate=true;
                end
            end
        end

        outFixed=reinterpretcast(bitsliceget(mant_rounded,wl,1),numerictype(Signed,WordLength,FracLength));
    end

    if saturate
        outFixed=cf2fixed_Saturate(Signed,WordLength,FracLength,aSign);
    end
end



function[exp_norm,mant_norm]=cf2fixed_Normalize_Exp_Mant(cfType,exp_cor,mant_cor,denormal)
    if(denormal)
        [exp_norm,mant_norm]=cf2fixed_Normalize_Exp_Mant_Denormal(cfType,exp_cor,mant_cor);
    else
        [exp_norm,mant_norm]=cf2fixed_Normalize_Exp_Mant_Normal(cfType,exp_cor,mant_cor);
    end
end


function[exp_norm,mant_norm]=cf2fixed_Normalize_Exp_Mant_Denormal(cfType,exp_a,mant_a)
    if(bitget(mant_a,mant_a.WordLength)==0)
        ia=int16(mant_a.WordLength)-int16(coder.customfloat.helpers.findFirst1(mant_a));
        exp_norm=int16(1)-ia;
        mant_a(:)=bitsll(mant_a,ia);
    else
        exp_norm=int16(exp_a);
    end

    mant_norm=reinterpretcast(mant_a,numerictype(0,cfType.MantissaLength+1,cfType.MantissaLength));
end


function[exp_norm,mant_norm]=cf2fixed_Normalize_Exp_Mant_Normal(cfType,exp_a,mant_a)
    exp_norm=int16(exp_a);
    mant_norm=reinterpretcast(mant_a,numerictype(0,cfType.MantissaLength+1,cfType.MantissaLength));
end


function outFixed=cf2fixed_Inf_or_NaN(aSign,aMantissa,Signed,WordLength,FracLength)
    if(aMantissa~=0)

        outFixed=fi(0,Signed,WordLength,FracLength);
    else
        outFixed=cf2fixed_Saturate(Signed,WordLength,FracLength,aSign);
    end
end

function outFixed=cf2fixed_Saturate(Signed,WordLength,FracLength,neg)
    if Signed

        outFixed=reinterpretcast(bitconcat(fi(0,0,1,0),bitcmp(fi(0,0,WordLength-1,0))),...
        numerictype(Signed,WordLength,FracLength));
        if neg

            outFixed(:)=bitcmp(outFixed);
        end
    else
        if neg

            outFixed=fi(0,Signed,WordLength,FracLength);
        else

            outFixed=bitcmp(fi(0,Signed,WordLength,FracLength));
        end
    end
end