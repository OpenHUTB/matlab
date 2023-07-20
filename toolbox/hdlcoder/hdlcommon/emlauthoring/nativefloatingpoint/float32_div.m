%#codegen
function[S,E,M]=float32_div(AS,AE,AM,BS,BE,BM,Simp)


    coder.allowpcode('plain')

    S=(AS~=BS);
    if Simp
        [E,M]=float32_div_nrm(AE,AM,BE,BM);
    else
        [E,M]=float32_div_reg(AE,AM,BE,BM);
    end
end


function[E,M]=float32_div_reg(AE,AM,BE,BM)

    if(AE==255)
        E=uint8(255);
        M=uint32((AM~=0)||(BE==255));
        return
    end

    if(BE==255)
        if(BM~=0)
            E=uint8(255);
            M=uint32(1);
        else
            E=uint8(0);
            M=uint32(0);
        end
        return
    end



    A_denorm=(AE==0);
    B_denorm=(BE==0);
    A_zero=A_denorm&&(AM==0);
    B_zero=B_denorm&&(BM==0);



    if(B_zero)
        E=uint8(255);
        M=uint32(A_zero);
        return
    end


    if(A_zero)
        E=uint8(0);
        M=uint32(0);
        return;
    end




    AEI=int16(AE);
    if(A_denorm)
        Z=count_leading_zeros24(AM);
        AM=shift_left(AM,Z);
        AEI=AEI-int16(Z)+1;
    else
        AM=bitset(AM,24);
    end

    BEI=int16(BE);
    if(B_denorm)
        Z=count_leading_zeros24(BM);
        BM=shift_left(BM,Z);
        BEI=BEI-int16(Z)+1;
    else
        BM=bitset(BM,24);
    end




    E16=AEI-BEI+127;
    if(E16>255)
        E=uint8(255);
        M=uint32(0);
        return
    end

    AM64=bitshift(uint64(AM),32);
    BM64=uint64(BM);
    M64=idivide(AM64,BM64);
    TrSuf=((M64*BM64)~=AM64);

    if(bitget(M64,33))
        M=bitshift(M64,-9);
        TrOne=logical(bitget(M64,9));
    else
        M=bitshift(M64,-8);
        TrOne=logical(bitget(M64,8));
        E16=E16-1;
    end


    if(E16<=0)
        E=uint8(0);
        Sh=1-E16;
        if(Sh>24)
            M=uint32(0);
            return;
        end
        Mask=bitshift(1,Sh-1);
        TrSuf=TrSuf||TrOne||(bitand(M,Mask-1)~=0);
        TrOne=bitand(M,Mask)~=uint32(0);
        M=shift_right(M,Sh);
    else
        E=uint8(E16);
    end

    [E,M]=float32_round(E,M,TrOne,TrSuf);
end


function[E,M]=float32_div_nrm(AE,AM,BE,BM)



    if(AE==255)
        E=uint8(255);
        M=uint32((AM~=0)||(BE==255));
        return
    end

    if(BE==255)
        if(BM~=0)
            E=uint8(255);
            M=uint32(1);
        else
            E=uint8(0);
            M=uint32(0);
        end
        return
    end


    if(BE==0)
        E=uint8(255);
        M=uint32(AE==0);
        return
    end


    if(AE==0)
        E=uint8(0);
        M=uint32(0);
        return;
    end





    E16=int16(AE)-int16(BE)+127;
    if(E16>255)
        E=uint8(255);
        M=uint32(0);
        return
    end

    BM=bitset(BM,24);
    AM=bitset(AM,24);
    AM64=bitshift(uint64(AM),32);
    BM64=uint64(BM);
    M64=idivide(AM64,BM64);
    TrSuf=((M64*BM64)~=AM64);

    if(bitget(M64,33))
        M=bitshift(M64,-9);
        TrOne=logical(bitget(M64,9));
    else
        M=bitshift(M64,-8);
        TrOne=logical(bitget(M64,8));
        E16=E16-1;
    end


    if(E16<=0)
        E=uint8(0);
        M=uint32(0);
        return
    else
        E=uint8(E16);
    end

    [E,M]=float32_round(E,M,TrOne,TrSuf);
end

