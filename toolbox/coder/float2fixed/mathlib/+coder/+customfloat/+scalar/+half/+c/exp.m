%#codegen











function outVal=exp(bitPattern)

    coder.allowpcode('plain');
    HALF_EXPONENT_MASK=coder.const(uint16(31744));
    HALF_MANTISSA_MASK=coder.const(uint16(1023));
    UINT16_ZERO=coder.const(uint16(0));
    UINT16_ONE=coder.const(uint16(1));

    [aSign,aExponent,aMantissa]=coder.customfloat.helpers.half.getHalfComponents(bitPattern);
    Mantissa=UINT16_ZERO;
    if aExponent==HALF_EXPONENT_MASK

        Mantissa=aMantissa;

        if(aMantissa~=UINT16_ZERO)||(aSign==UINT16_ZERO)

            Sign=aSign;
            Exponent=aExponent;
        else

            Sign=UINT16_ZERO;
            Exponent=UINT16_ZERO;
        end
    else

        Sign=UINT16_ZERO;


        aExponent=bitshift(aExponent,-10);

        if aExponent==UINT16_ZERO
            aExponent=UINT16_ONE;
        else

            aMantissa=bitor(aMantissa,uint16(1024));
        end



        Log2_E=coder.const(uint32(94548));
        prod=uint32(aMantissa)*Log2_E;
        tmp2=bitshift(prod+uint32(512),-10);

        if bitshift(tmp2,-17)~=0
            aExponent=aExponent+1;
            tmp2=bitshift(tmp2,-1);
        end


        exp_tmp=int16(aExponent);

        if aSign~=UINT16_ZERO
            upperbound=coder.const(int16(20));
        else
            upperbound=coder.const(int16(19));
        end

        if(exp_tmp>=upperbound)


            if aSign==UINT16_ZERO
                Exponent=HALF_EXPONENT_MASK;
            else
                Exponent=UINT16_ZERO;
            end
        else
            exp_tmp=exp_tmp-15;
            tmp2=bitshift(tmp2,exp_tmp);



            mant_frac=bitand(int32(tmp2),int32(65535));
            mant_tmp=int32(2^16)-mant_frac;
            sticky=mant_frac~=int32(0);
            exp_tmp=int16(bitshift(tmp2,-16));
            exp_adj=coder.const(int16(15));

            if aSign==UINT16_ZERO
                exp_tmp=exp_tmp+exp_adj;
            else
                if sticky
                    mant_frac=mant_tmp;
                    exp_adj=exp_adj-1;
                end
                exp_tmp=exp_adj-exp_tmp;
            end


            w=bitshift(mant_frac,1);

            if bitand(w,int32(65536))~=int32(0)
                w=w-76672;
                y=coder.const(int32(98304));
            else
                y=coder.const(int32(65536));
            end


            w=bitshift(w,1);
            tmp=bitshift(y,-2);

            if w<0&&bitand(w,int32(65536))==0
                w=w+108800;
                y=y-tmp;

            elseif w>0&&bitand(w,int32(65536))~=0
                w=w-84392;
                y=y+tmp;
            end


            w=bitshift(w,1);
            tmp=bitshift(y,-3);

            if w<0&&bitand(w,int32(65536))==0
                w=w+101002;
                y=y-tmp;

            elseif w>0&&bitand(w,int32(65536))~=0
                w=w-89090;
                y=y+tmp;
            end


            w=bitshift(w,1);
            tmp=bitshift(y,-4);

            if w<0&&bitand(w,int32(65536))==0
                w=w+97632;
                y=y-tmp;

            elseif w>0&&bitand(w,int32(65536))~=0
                w=w-91712;
                y=y+tmp;
            end


            w=bitshift(w,1);
            tmp=bitshift(y,-5);

            if w<0&&bitand(w,int32(65536))==0
                w=w+96058;
                y=y-tmp;

            elseif w>0&&bitand(w,int32(65536))~=0
                w=w-93102;
                y=y+tmp;
            end




            tmp3=bitshift(w*1420,-14);
            tmp3=tmp3*bitshift(y,-3);
            y=y+bitshift(tmp3,-15);


            if exp_tmp<=0
                shift_length=1-exp_tmp;
                if shift_length>=19
                    y=int32(0);
                else
                    y=bitshift(y,-shift_length);
                end
            end

            if bitand(y,int32(65536))~=0
                Exponent=uint16(exp_tmp);
            else
                Exponent=UINT16_ZERO;
            end

            Mantissa=uint16(bitshift(bitand(y,65535),-6));


            round=bitand(y,32)~=0;
            if round&&(sticky||(bitand(y,64)~=0))
                Mantissa=Mantissa+1;
            end
            if Mantissa>HALF_MANTISSA_MASK
                Exponent=Exponent+1;
                Mantissa=UINT16_ZERO;
            end
            Exponent=bitshift(Exponent,10);
        end
    end

    outVal=bitor(Sign,bitor(Exponent,Mantissa));
end
