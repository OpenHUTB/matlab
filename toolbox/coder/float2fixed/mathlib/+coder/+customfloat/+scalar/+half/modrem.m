%#codegen



















function cHalf=modrem(aHalf,bHalf,mod_or_rem,denormal)
    coder.inline('never');
    coder.allowpcode('plain');


    [aSign,aExponent,aMantissa]=coder.customfloat.helpers.half.getHalfComponents(aHalf);
    [bSign,bExponent,bMantissa]=coder.customfloat.helpers.half.getHalfComponents(bHalf);
    aSign=bitshift(aSign,-15);aExponent=bitshift(aExponent,-10);
    bSign=bitshift(bSign,-15);bExponent=bitshift(bExponent,-10);


    [aExponent,aMantissa]=checkDenormal(aExponent,aMantissa,denormal);
    [bExponent,bMantissa]=checkDenormal(bExponent,bMantissa,denormal);

    if(modrem_Exceptional_Check(aExponent,aMantissa,bExponent,bMantissa))


        [Sign,Exponent,Mantissa]=modrem_Set_Exceptional_Cases(aSign,aExponent,aMantissa,bSign,bExponent,bMantissa,mod_or_rem);
    else
        Sign=modrem_Set_Sign(aSign,bSign,mod_or_rem);

        [exp_a_cor,mant_a_cor]=coder.customfloat.helpers.half.appendMantissaAndCorrectExponent(aExponent,aMantissa);
        [exp_b_cor,mant_b_cor]=coder.customfloat.helpers.half.appendMantissaAndCorrectExponent(bExponent,bMantissa);
        [Exponent,Mantissa]=modrem_Main(bitxor(aSign,bSign),exp_a_cor,mant_a_cor,exp_b_cor,mant_b_cor,mod_or_rem,denormal);
    end


    cHalf=coder.customfloat.helpers.half.collapseHalfComponents(Sign,Exponent,Mantissa);
end










function[Exponent,Mantissa]=modrem_Main(sign_diff,exp_a_cor,mant_a_cor,exp_b_cor,mant_b_cor,mod_or_rem,denormal)
    coder.inline('never');


    [exp_a_norm,mant_a_norm,exp_b_norm,mant_b_norm]=modrem_Normalize_Exp_Mant(exp_a_cor,mant_a_cor,exp_b_cor,mant_b_cor);


    [R,exp_diff]=modrem_Prep(exp_a_norm,exp_b_norm,mant_a_norm);

    mant_a_greater=(mant_a_norm>mant_b_norm);

    if exp_diff<0

        R=mant_a_norm;
        exp_R=exp_a_norm;
    elseif mant_a_norm==mant_b_norm

        R=uint16(0);
        exp_R=int16(0);
    elseif isInt(exp_b_norm,mant_b_norm)

        R=modrem_Iteration(R,mant_b_norm);
        R=modrem_Full_Iterations(R,exp_diff-1,mant_b_norm);
        exp_R=exp_b_norm;
    elseif(mant_a_greater&&exp_diff>=12)||(~mant_a_greater&&exp_diff>=13)

        R=uint16(0);
        exp_R=int16(0);
    else

        R=modrem_Iteration(R,mant_b_norm);
        R=modrem_Full_Iterations(R,exp_diff-1,mant_b_norm);
        exp_R=exp_b_norm;
        if checkResetToZero(R,exp_diff,mant_a_greater,mant_b_norm)
            R=uint16(0);
            exp_R=int16(0);
        end
    end


    roundBit=uint16(0);
    sticky=false;



    if(mod_or_rem==1)&&sign_diff&&(R~=0)
        if exp_diff<0

            [R,exp_offset,roundBit,sticky]=modrem_Subtract(mant_b_norm,R,-exp_diff);
            exp_R=exp_b_norm-exp_offset;
        else

            R=mant_b_norm-R;
        end
    end


    [Mantissa,Exponent]=modrem_Normalize_Ans(R,exp_R,roundBit,sticky,denormal);
end






function[R,exp_offset,roundBit,sticky]=modrem_Subtract(mant_b_norm,R,exp_diff)

    mant_b_norm=bitshift(mant_b_norm,2);



    stickyMask=uint16([0,0,1,3,7,15,31,63,127,255,511,1023,2047]);
    index=min(exp_diff,13);
    stickyBits=bitand(R,stickyMask(index));
    sticky=(stickyBits>0);


    R=bitshift(R,-(exp_diff-2));


    R=mant_b_norm-R;
    if sticky
        R=R-uint16(1);
    end



    if bitget(R,13)
        sticky=(sticky||bitget(R,1));
        roundBit=bitget(R,2);
        R=bitshift(R,-2);
        exp_offset=int16(0);
    else
        roundBit=bitget(R,1);
        R=bitshift(R,-1);
        exp_offset=int16(1);
    end
end




function[mant_R,exp_R]=modrem_Normalize_Ans(R,exp_R,roundBit,sticky,denormal)
    coder.inline('never');

    exp_shift=coder.customfloat.helpers.half.findFirst1(R);
    exp_R_norm=exp_R-exp_shift;

    if R==0
        exp_R=uint16(0);
        mant_R=uint16(0);
    elseif exp_R_norm<1
        mant_R=modrem_Round_Denormals(R,exp_R_norm,exp_shift,roundBit,sticky);
        if bitget(mant_R,11)
            exp_R=uint16(1);
            mant_R=uint16(0);
        elseif~denormal
            exp_R=uint16(0);
            mant_R=uint16(0);
        else
            exp_R=uint16(0);
        end
    else

        mant_R_norm=bitshift(R,exp_shift);
        [mant_R_norm,exp_R_norm]=modrem_Round_Normals(mant_R_norm,exp_R_norm,roundBit,sticky);

        mant_R=bitand(mant_R_norm,uint16(1023));

        exp_R=uint16(exp_R_norm);
    end

end


function[mantRounded,expRounded]=modrem_Round_Normals(mant_R_norm,exp_R_norm,roundBit,sticky)
    expRounded=exp_R_norm;

    LSB=bitget(mant_R_norm,1);
    if roundBit&&(sticky||LSB)

        mantRounded=mant_R_norm+uint16(1);
    else
        mantRounded=mant_R_norm;
    end


    if bitget(mantRounded,12)
        mantRounded=uint16(1024);
        expRounded=exp_R_norm+int16(1);
    end
end


function mantRounded=modrem_Round_Denormals(R,exp_R_norm,exp_shift,roundBit,sticky)


    roundBitPos=(int16(1)-exp_R_norm)-exp_shift;
    roundBitPos=min(roundBitPos,11);
    if roundBitPos<=0
        sticky=false;
        roundBit=uint16(0);
        LSB=uint16(0);
    else

        stickyMask=uint16([0,1,3,7,15,31,63,127,255,511,1023]);
        stickyBits=bitand(R,stickyMask(roundBitPos));


        sticky=(roundBit||sticky)||(stickyBits>0);
        roundBit=bitget(R,roundBitPos);
        LSB=bitget(R,roundBitPos+1);
    end

    if roundBit&&(sticky||LSB)

        roundBitMask=uint16([2,4,8,16,32,64,128,256,512,1024,2048]);
        R=R+roundBitMask(roundBitPos);


        mantRounded=bitshift(R,exp_shift-(int16(1)-exp_R_norm));
    else

        mantRounded=bitshift(R,exp_shift-(int16(1)-exp_R_norm));
    end
end









function reset_to_zero=checkResetToZero(R,exp_diff,mant_a_greater,mant_b_norm)

    if(bitshift(R,1)>mant_b_norm)
        LHS=uint32(mant_b_norm-R);
    else
        LHS=uint32(R);
    end



    if mant_a_greater
        shift=int16(11)-exp_diff;
    else
        shift=int16(12)-exp_diff;
    end


    if bitshift(LHS,shift)<=mant_b_norm
        reset_to_zero=true;
    else
        reset_to_zero=false;
    end
end



function out=isInt(exp_norm,mant_norm)
    p=coder.customfloat.helpers.half.findLast1(mant_norm);
    if(exp_norm-p-int16(15)<0)
        out=false;
    else
        out=true;
    end
end




function[R_out,exp_diff]=modrem_Prep(exp_a_norm,exp_b_norm,mant_a_norm)
    R_out=mant_a_norm;
    exp_diff=exp_a_norm-exp_b_norm;
end


function R_out=modrem_Iteration(R,mant_b_norm)
    if R<mant_b_norm
        R_out=R;
    else
        R_out=R-mant_b_norm;
    end
end





function R=modrem_Full_Iterations(R,exp_diff,mant_b_norm)
    while exp_diff>=0
        R=modrem_Iteration(bitshift(R,1),mant_b_norm);
        exp_diff=exp_diff-int16(1);
    end
end







function[exp_a_norm,mant_a_norm,exp_b_norm,mant_b_norm]=modrem_Normalize_Exp_Mant(exp_a,mant_a,exp_b,mant_b)
    coder.inline('never');

    if(bitget(mant_a,11)==0)


        ia=coder.customfloat.helpers.half.findFirst1(mant_a);
        exp_a_norm=int16(1)-ia;
        mant_a_norm=bitshift(mant_a,ia);
    else
        exp_a_norm=int16(exp_a);
        mant_a_norm=mant_a;
    end

    if(bitget(mant_b,11)==0)
        ib=coder.customfloat.helpers.half.findFirst1(mant_b);
        exp_b_norm=int16(1)-ib;
        mant_b_norm=bitshift(mant_b,ib);
    else
        exp_b_norm=int16(exp_b);
        mant_b_norm=mant_b;
    end
end







function exception=modrem_Exceptional_Check(aExponent,aMantissa,bExponent,bMantissa)

    Exponent_Inf_or_NaN=uint16(31);

    exception=((aExponent==Exponent_Inf_or_NaN)||...
    (bExponent==Exponent_Inf_or_NaN)||...
    ((aExponent==0)&&(aMantissa==0))||...
    ((bExponent==0)&&(bMantissa==0)));
end


function[Sign,Exponent,Mantissa]=modrem_Set_Exceptional_Cases(aSign,aExponent,aMantissa,bSign,bExponent,bMantissa,mod_or_rem)
    if(mod_or_rem==1)
        [Sign,Exponent,Mantissa]=mod_Set_Exceptional_Cases(aSign,aExponent,aMantissa,bSign,bExponent,bMantissa);
    else
        [Sign,Exponent,Mantissa]=rem_Set_Exceptional_Cases(aSign,aExponent,aMantissa,bSign,bExponent,bMantissa);
    end
end




function[Sign,Exponent,Mantissa]=rem_Set_Exceptional_Cases(aSign,aExponent,aMantissa,bSign,bExponent,bMantissa)
    Exponent_Inf_or_NaN=uint16(31);
    Mantissa_NaN=uint16(512);


    Sign=aSign;


    if(aExponent==Exponent_Inf_or_NaN)&&(aMantissa~=0)

        Exponent=aExponent;
        Mantissa=aMantissa;
    elseif(bExponent==Exponent_Inf_or_NaN)&&(bMantissa~=0)

        Exponent=bExponent;
        Mantissa=bMantissa;
    elseif(aExponent==Exponent_Inf_or_NaN)||((bExponent==0)&&(bMantissa==0))

        Exponent=Exponent_Inf_or_NaN;
        Mantissa=Mantissa_NaN;
    else

        Exponent=aExponent;
        Mantissa=aMantissa;
    end
end





function[Sign,Exponent,Mantissa]=mod_Set_Exceptional_Cases(aSign,aExponent,aMantissa,bSign,bExponent,bMantissa)
    Exponent_Inf_or_NaN=uint16(31);
    Mantissa_NaN=uint16(512);

    Sign=bSign;

    if((bExponent==0)&&(bMantissa==0))||((aExponent==Exponent_Inf_or_NaN)&&(aMantissa~=0))

        if(aExponent~=0)||(aMantissa~=0)
            Sign=aSign;
        end
        Exponent=aExponent;
        Mantissa=aMantissa;
    elseif(bExponent==Exponent_Inf_or_NaN)&&(bMantissa~=0)

        Exponent=bExponent;
        Mantissa=bMantissa;
    elseif(aExponent==Exponent_Inf_or_NaN)

        Exponent=Exponent_Inf_or_NaN;
        Mantissa=Mantissa_NaN;
    elseif(aExponent==0)&&(aMantissa==0)

        Exponent=uint16(0);
        Mantissa=uint16(0);
    else

        if(aSign~=bSign)
            Exponent=bExponent;
            Mantissa=bMantissa;
        else
            Exponent=aExponent;
            Mantissa=aMantissa;
        end
    end
end





function[Exponent,Mantissa]=checkDenormal(inExponent,inMantissa,denormal)
    coder.allowpcode('plain');

    Exponent=inExponent;

    if(denormal)
        Mantissa=inMantissa;
    else
        if(inExponent==0)
            Mantissa=uint16(0);
        else
            Mantissa=inMantissa;
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

