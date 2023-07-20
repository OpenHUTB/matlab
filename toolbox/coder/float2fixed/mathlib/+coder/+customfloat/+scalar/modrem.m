%#codegen










function[Sign,Exponent,Mantissa]=modrem(cfType,aSign,aExponent,aMantissa,bSign,bExponent,bMantissa,mod_or_rem,denormal)

    coder.allowpcode('plain');




    Sign=modrem_Set_Sign(aSign,bSign,mod_or_rem);
    oppSign=bitxor(aSign,bSign);

    [aExponent,aMantissa]=coder.customfloat.helpers.checkDenormal(cfType,aExponent,aMantissa,denormal);
    [bExponent,bMantissa]=coder.customfloat.helpers.checkDenormal(cfType,bExponent,bMantissa,denormal);

    if(modrem_Exceptional_Check(cfType,aExponent,aMantissa,bExponent,bMantissa))
        [Exponent,Mantissa]=modrem_Set_Exceptional_Cases(cfType,aExponent,aMantissa,bExponent,bMantissa,mod_or_rem,oppSign);
    else
        [exp_a_cor,mant_a_cor]=coder.customfloat.helpers.appendMantissaAndCorrectExponent(cfType,aExponent,aMantissa);
        [exp_b_cor,mant_b_cor]=coder.customfloat.helpers.appendMantissaAndCorrectExponent(cfType,bExponent,bMantissa);
        [Exponent,Mantissa]=modrem_Main(cfType,oppSign,exp_a_cor,mant_a_cor,exp_b_cor,mant_b_cor,mod_or_rem,denormal);
    end
end

function[Exponent,Mantissa]=modrem_Main(cfType,sign_diff,exp_a_cor,mant_a_cor,exp_b_cor,mant_b_cor,mod_or_rem,denormal)


    [exp_a_norm,mant_a_norm,exp_b_norm,mant_b_norm]=modrem_Normalize_Exp_Mant(cfType,exp_a_cor,mant_a_cor,exp_b_cor,mant_b_cor,denormal);


    [exp_diff,mB,m2B,m3B]=modrem_Prep(exp_a_norm,exp_b_norm,mant_b_norm);




    [R,exp_2diff,mB,m2B,m3B]=modrem_First_Iteration(exp_diff,mant_a_norm,mB,m2B,m3B);






    [R,exp_2diff,mB,m2B,m3B]=modrem_Full_Iterations(R,exp_2diff,mB,m2B,m3B,1,ceil(cfType.MantissaLength/2));


    b_is_Int=isInt(cfType,exp_b_norm,mant_b_norm);


    reset_to_zero=checkResetToZero(cfType,exp_diff,exp_2diff,R,mant_a_norm,mant_b_norm,b_is_Int);


    [R,~,~,~,~]=modrem_Full_Iterations(R,exp_2diff,mB,m2B,m3B,ceil(cfType.MantissaLength/2)+1,(2^(cfType.ExponentLength-2)-1));

    [exp_R,R_out,reset_to_zero,sticky]=Mod_Rem(cfType,R,exp_a_norm,exp_b_norm,reset_to_zero,mB,sign_diff,mod_or_rem);


    [Exp,mant_norm,sticky]=modrem_Normalize(cfType,exp_R,R_out,reset_to_zero,sticky,denormal);


    if(denormal)
        [Exponent,Mantissa]=coder.customfloat.helpers.rounding(Exp,mant_norm,sticky);
    else
        [Exponent,Mantissa]=coder.customfloat.helpers.rounding_normals(Exp,mant_norm,sticky);
    end
end




function[exp_R,R_out,reset_to_zero,sticky]=Mod_Rem(cfType,R_in,exp_a_norm,exp_b_norm,reset_to_zero,mB1,sign_diff,mod_or_rem)
    if(mod_or_rem==1)
        [exp_R,R_out,reset_to_zero,sticky]=Mod(cfType,R_in,exp_a_norm,exp_b_norm,reset_to_zero,mB1,sign_diff);
    elseif(mod_or_rem==2)
        [exp_R,R_out,reset_to_zero,sticky]=Rem(cfType,R_in,exp_a_norm,exp_b_norm,reset_to_zero,mB1,sign_diff);
    end
end







function[exp_R,R_out,reset_to_zero,sticky]=Rem(cfType,R_in,exp_a_norm,exp_b_norm,reset_to_zero,mB1,sign_diff)
    R_out=bitconcat(bitsliceget(R_in,cfType.MantissaLength+1,1),fi(0,0,1,0));
    sticky=false;
    if(exp_a_norm<exp_b_norm)
        exp_R=exp_a_norm;
    else
        exp_R=exp_b_norm;
    end
end


function[exp_R,R_out,reset_to_zero,sticky]=Mod(cfType,R_in,exp_a_norm,exp_b_norm,reset_to_zero,mB1,sign_diff)
    exp_R=exp_b_norm;
    R_ext=reinterpretcast(bitconcat(R_in,fi(0,0,2,0)),numerictype(1,cfType.MantissaLength+7,0));
    mB1_ext=reinterpretcast(bitconcat(-mB1,fi(0,0,2,0)),numerictype(1,cfType.MantissaLength+7,0));
    sticky=false;

    if(sign_diff==1)&&(R_in~=0)


        R_ext(:)=-R_ext;
        shift_length=cast(exp_b_norm-exp_a_norm,'like',exp_a_norm);
        if(shift_length>0)
            if(shift_length>=cfType.MantissaLength+3)
                sticky=true;
                R_ext(:)=-1;
            else
                tmp1=bitsll(R_ext,cast(R_ext.WordLength,'like',exp_a_norm)-shift_length);
                sticky=(tmp1~=0);
                R_ext(:)=bitsra(R_ext,shift_length);
            end
        end

        R_ext(:)=(mB1_ext+R_ext);

        if(bitget(R_ext,cfType.MantissaLength+3)==0)&&(bitget(R_ext,cfType.MantissaLength+2)==1)

            R_ext(:)=bitsll(R_ext,1);
            exp_R(:)=exp_R-cast(1,'like',exp_R);
        end

        sticky=sticky||(bitget(R_ext,1)==1);
    else
        if(exp_a_norm<exp_b_norm)
            exp_R=exp_a_norm;
        end
    end

    R_out=bitsliceget(R_ext,cfType.MantissaLength+3,2);
end


function[Exp,mant_norm,sticky]=modrem_Normalize(cfType,exp_R,R_out,reset_to_zero,sticky,denormal)
    if(denormal)
        [Exp,mant_norm,sticky]=modrem_Normalize_Denormals(cfType,exp_R,R_out,reset_to_zero,sticky);
    else
        [Exp,mant_norm,sticky]=modrem_Normalize_Normals(cfType,exp_R,R_out,reset_to_zero,sticky);
    end
end


function[Exp,mant_norm,sticky]=modrem_Normalize_Denormals(cfType,exp_R,R,reset_to_zero,sticky)
    if reset_to_zero||(R==0)
        Exp=fi(0,0,cfType.ExponentLength,0);
        mant_norm=fi(0,0,cfType.MantissaLength+1,0);
    else
        tmp1=bitsliceget(R,cfType.MantissaLength+2,2);
        shift1=cast(cfType.MantissaLength+1,'like',exp_R)-cast(coder.customfloat.helpers.findFirst1(tmp1),'like',exp_R);
        tmp2=bitsliceget(R,cfType.MantissaLength+2,1);
        if(shift1>cfType.MantissaLength+1)
            tmp3=fi(0,0,cfType.MantissaLength+2,0);
        else
            tmp3=bitsll(tmp2,shift1);
        end

        exp_rem=cast(exp_R-shift1,'like',exp_R);

        if(exp_rem>0)

            Exp=fi(exp_rem,0,cfType.ExponentLength,0);

            mant_norm=bitsliceget(tmp3,cfType.MantissaLength+1,1);
        else
            Exp=fi(0,0,cfType.ExponentLength,0);

            if(exp_rem<-(cfType.MantissaLength+1))

                mant_norm=fi(0,0,cfType.MantissaLength+1,0);
            else

                shift2=cast(cast(1,'like',exp_R)-exp_rem,'like',exp_R);
                if(shift2>1)
                    sticky=sticky||(bitsll(tmp3,tmp3.WordLength+1-shift2)~=0);
                end
                mant_norm=bitsliceget(bitsrl(tmp3,shift2),cfType.MantissaLength+1,1);
            end
        end

    end
end


function[Exp,mant_norm,sticky]=modrem_Normalize_Normals(cfType,exp_R,R,reset_to_zero,sticky)
    if reset_to_zero||(R==0)
        Exp=fi(0,0,cfType.ExponentLength,0);
        mant_norm=fi(0,0,cfType.MantissaLength+1,0);
    else
        tmp1=bitsliceget(R,cfType.MantissaLength+2,2);
        shift1=cast(cfType.MantissaLength+1,'like',exp_R)-cast(coder.customfloat.helpers.findFirst1(tmp1),'like',exp_R);
        tmp2=bitsliceget(R,cfType.MantissaLength+2,1);
        if(shift1>cfType.MantissaLength+1)
            tmp3=fi(0,0,cfType.MantissaLength+2,0);
        else
            tmp3=bitsll(tmp2,shift1);
        end

        exp_rem=cast(exp_R-shift1,'like',exp_R);

        if(exp_rem>0)

            Exp=fi(exp_rem,0,cfType.ExponentLength,0);

            mant_norm=bitsliceget(tmp3,cfType.MantissaLength+1,1);
        else
            Exp=fi(0,0,cfType.ExponentLength,0);

            if(exp_rem<0)

                mant_norm=fi(0,0,cfType.MantissaLength+1,0);
            else
                mant_norm=bitsliceget(bitsrl(tmp3,1),cfType.MantissaLength+1,1);
            end
        end
    end
end






function reset_to_zero=checkResetToZero(cfType,exp_diff,exp_2diff,R,mant_a_norm,mant_b_norm,b_is_Int)

    if(bitsll(R,1)>=mant_b_norm)
        x=cast(mant_b_norm-R,'like',mant_b_norm);
    else
        x=R;
    end



    tmp=cast(cfType.MantissaLength+1,'like',exp_diff);
    pos=cast(exp_diff-max(exp_2diff,-1),'like',exp_diff);
    shift_length=cast(tmp-pos,'like',exp_diff);

    if b_is_Int||(exp_diff<0)
        reset_to_zero=false;
    elseif(shift_length<0)
        reset_to_zero=true;
    else

        if(x==0)
            reset_to_zero=true;
        else
            if(pos<=0)
                reset_to_zero=false;
            else
                if(bitsrl(x,pos)~=0)
                    reset_to_zero=false;
                else
                    tmp1=bitsll(x,shift_length);
                    tmp2=bitsliceget(tmp1,cfType.MantissaLength+1,1);
                    tmp3=bitsliceget(mant_a_norm,cfType.MantissaLength+1,1);
                    reset_to_zero=(tmp2<tmp3);
                end
            end
        end
    end
end


function out=isInt(cfType,exp_norm,mant_norm)
    p=cast(cfType.MantissaLength+1,'like',exp_norm)-cast(coder.customfloat.helpers.findLast1(mant_norm),'like',exp_norm);
    if(exp_norm-p-cfType.ExponentBias<0)
        out=false;
    else
        out=true;
    end
end






function[exp_diff,mB_out,m2B_out,m3B_out]=modrem_Prep(exp_a_norm,exp_b_norm,mant_b_norm)
    tmp1=bitsll(mant_b_norm,1);
    tmp2=cast(tmp1+mant_b_norm,'like',mant_b_norm);
    mB_out=-mant_b_norm;
    m2B_out=-tmp1;
    m3B_out=-tmp2;

    exp_diff=cast(exp_a_norm-exp_b_norm,'like',exp_a_norm);
end









function[R_out,exp_diff_out,mB,m2B,m3B]=modrem_First_Iteration(exp_diff,mant_a_norm,mB,m2B,m3B)
    if(exp_diff<0)
        exp_diff_out=cast(exp_diff-cast(1,'like',exp_diff),'like',exp_diff);
        R_out=mant_a_norm;
    else
        if(bitget(exp_diff,1)==0)
            exp_diff_out=cast(exp_diff-cast(1,'like',exp_diff),'like',exp_diff);

            tmp=cast(mant_a_norm+mB,'like',mant_a_norm);
            if(tmp<0)
                R_out=mant_a_norm;
            else
                R_out=tmp;
            end
        else
            exp_diff_out=cast(exp_diff-cast(2,'like',exp_diff),'like',exp_diff);

            tmp1=bitsll(mant_a_norm,1);
            tmp2=cast(tmp1+mB,'like',mant_a_norm);
            tmp3=cast(tmp1+m2B,'like',mant_a_norm);
            tmp4=cast(tmp1+m3B,'like',mant_a_norm);

            if(tmp2<0)
                R_out=tmp1;
            elseif(tmp3<0)
                R_out=tmp2;
            elseif(tmp4<0)
                R_out=tmp3;
            else
                R_out=tmp4;
            end
        end
    end
end


function[R,exp_diff,mB,m2B,m3B]=modrem_Full_Iterations(R,exp_diff,mB,m2B,m3B,firstIndex,lastIndex)
    for ii=coder.unroll(firstIndex:1:lastIndex)
        [R,exp_diff,mB,m2B,m3B]=modrem_Iteration(R,exp_diff,mB,m2B,m3B);
    end
end








function[R_out,exp_diff_out,mB,m2B,m3B]=modrem_Iteration(R_in,exp_diff_in,mB,m2B,m3B)
    tmp1=bitsll(R_in,2);
    tmp2=cast(tmp1+mB,'like',R_in);
    tmp3=cast(tmp1+m2B,'like',R_in);
    tmp4=cast(tmp1+m3B,'like',R_in);

    if(exp_diff_in<0)
        R_out=R_in;
    else
        if(tmp2<0)
            R_out=tmp1;
        elseif(tmp3<0)
            R_out=tmp2;
        elseif(tmp4<0)
            R_out=tmp3;
        else
            R_out=tmp4;
        end
    end

    exp_diff_out=cast(exp_diff_in-cast(2,'like',exp_diff_in),'like',exp_diff_in);
end



function[exp_a_norm,mant_a_norm,exp_b_norm,mant_b_norm]=modrem_Normalize_Exp_Mant(cfType,exp_a,mant_a,exp_b,mant_b,denormal)
    if(denormal)
        [exp_a_norm,mant_a_norm,exp_b_norm,mant_b_norm]=modrem_Normalize_Exp_Mant_Denormals(cfType,exp_a,mant_a,exp_b,mant_b);
    else
        [exp_a_norm,mant_a_norm,exp_b_norm,mant_b_norm]=modrem_Normalize_Exp_Mant_Normals(cfType,exp_a,mant_a,exp_b,mant_b);
    end
end


function[exp_a_norm,mant_a_norm,exp_b_norm,mant_b_norm]=modrem_Normalize_Exp_Mant_Denormals(cfType,exp_a,mant_a,exp_b,mant_b)


    if(bitget(mant_a,mant_a.WordLength)==0)
        ia=int8(mant_a.WordLength)-int8(coder.customfloat.helpers.findFirst1(mant_a));
        exp_a_norm=fi(1-ia,1,cfType.ExponentLength+2,0);
        mant_a_norm=reinterpretcast(bitconcat(fi(0,0,4,0),bitsll(mant_a,ia)),numerictype(1,cfType.MantissaLength+5,0));
    else
        exp_a_norm=fi(exp_a,1,cfType.ExponentLength+2,0);
        mant_a_norm=reinterpretcast(bitconcat(fi(0,0,4,0),mant_a),numerictype(1,cfType.MantissaLength+5,0));
    end

    if(bitget(mant_b,mant_b.WordLength)==0)
        ib=int8(mant_b.WordLength)-int8(coder.customfloat.helpers.findFirst1(mant_b));
        exp_b_norm=fi(1-ib,1,cfType.ExponentLength+2,0);
        mant_b_norm=reinterpretcast(bitconcat(fi(0,0,4,0),bitsll(mant_b,ib)),numerictype(1,cfType.MantissaLength+5,0));
    else
        exp_b_norm=fi(exp_b,1,cfType.ExponentLength+2,0);
        mant_b_norm=reinterpretcast(bitconcat(fi(0,0,4,0),mant_b),numerictype(1,cfType.MantissaLength+5,0));
    end
end


function[exp_a_norm,mant_a_norm,exp_b_norm,mant_b_norm]=modrem_Normalize_Exp_Mant_Normals(cfType,exp_a,mant_a,exp_b,mant_b)


    exp_a_norm=fi(exp_a,1,cfType.ExponentLength+2,0);
    mant_a_norm=reinterpretcast(bitconcat(fi(0,0,4,0),mant_a),numerictype(1,cfType.MantissaLength+5,0));

    exp_b_norm=fi(exp_b,1,cfType.ExponentLength+2,0);
    mant_b_norm=reinterpretcast(bitconcat(fi(0,0,4,0),mant_b),numerictype(1,cfType.MantissaLength+5,0));
end


function exception=modrem_Exceptional_Check(cfType,aExponent,aMantissa,bExponent,bMantissa)
    exception=((aExponent==cfType.Exponent_Inf_or_NaN)||(bExponent==cfType.Exponent_Inf_or_NaN)||...
    ((aExponent==0)&&(aMantissa==0))||((bExponent==0)&&(bMantissa==0)));
end


function[Exponent,Mantissa]=modrem_Set_Exceptional_Cases(cfType,aExponent,aMantissa,bExponent,bMantissa,mod_or_rem,oppSign)
    if(mod_or_rem==1)
        [Exponent,Mantissa]=mod_Set_Exceptional_Cases(cfType,aExponent,aMantissa,bExponent,bMantissa,oppSign);
    else
        [Exponent,Mantissa]=rem_Set_Exceptional_Cases(cfType,aExponent,aMantissa,bExponent,bMantissa,oppSign);
    end
end

function[Exponent,Mantissa]=rem_Set_Exceptional_Cases(cfType,aExponent,aMantissa,bExponent,bMantissa,oppSign)
    if(aExponent==cfType.Exponent_Inf_or_NaN)&&(aMantissa~=0)

        Exponent=aExponent;
        Mantissa=aMantissa;
    elseif(bExponent==cfType.Exponent_Inf_or_NaN)&&(bMantissa~=0)

        Exponent=bExponent;
        Mantissa=bMantissa;
    elseif(aExponent==cfType.Exponent_Inf_or_NaN)||((bExponent==0)&&(bMantissa==0))

        Exponent=cfType.Exponent_Inf_or_NaN;
        Mantissa=cfType.Mantissa_NaN;
    else

        Exponent=aExponent;
        Mantissa=aMantissa;
    end
end

function[Exponent,Mantissa]=mod_Set_Exceptional_Cases(cfType,aExponent,aMantissa,bExponent,bMantissa,oppSign)
    if((bExponent==0)&&(bMantissa==0))||((aExponent==cfType.Exponent_Inf_or_NaN)&&(aMantissa~=0))

        Exponent=aExponent;
        Mantissa=aMantissa;
    elseif((bExponent==cfType.Exponent_Inf_or_NaN)&&(bMantissa~=0))

        Exponent=bExponent;
        Mantissa=bMantissa;
    elseif(aExponent==cfType.Exponent_Inf_or_NaN)

        Exponent=cfType.Exponent_Inf_or_NaN;
        Mantissa=cfType.Mantissa_NaN;
    elseif((aExponent==0)&&(aMantissa==0))

        Exponent=fi(0,0,cfType.ExponentLength,0);
        Mantissa=fi(0,0,cfType.MantissaLength,0);
    else

        if(oppSign)
            Exponent=bExponent;
            Mantissa=bMantissa;
        else
            Exponent=aExponent;
            Mantissa=aMantissa;
        end
    end
end



function Sign=modrem_Set_Sign(aSign,bSign,mod_or_rem)
    if(mod_or_rem==1)
        Sign=bSign;
    else
        Sign=aSign;
    end
end