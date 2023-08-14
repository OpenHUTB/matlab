%#codegen
function[Sout,Eout,Mout]=float32_mul_pipelined(AS,AE,AM,BS,BE,BM)



    persistent dS d2S d3S d4S d5S d6S d7S d8S d9S d10S d11S
    persistent dA_special dB_special
    persistent disAMnonzero disBMnonzero
    persistent dA_denorm dB_denorm
    persistent dAM d2AM d3AM
    persistent dBM d2BM d3BM
    persistent dAE d2AE
    persistent dBE d2BE
    persistent d2ZA d2ZB
    persistent d4M64 d5M64
    persistent d5NZ
    persistent d5E16
    persistent d3AEI d4AEI d3BEI d4BEI
    if isempty(dA_special)
        dS=false;
        d2S=false;
        d3S=false;
        d4S=false;
        d5S=false;
        d6S=false;
        d7S=false;
        d8S=false;
        d9S=false;
        d10S=false;
        d11S=false;

        dA_special=false;
        dB_special=false;

        disAMnonzero=false;
        disBMnonzero=false;

        dA_denorm=false;
        dB_denorm=false;

        dAM=uint32(0);
        d2AM=uint32(0);
        d3AM=uint32(0);

        dBM=uint32(0);
        d2BM=uint32(0);
        d3BM=uint32(0);

        dAE=uint8(0);
        d2AE=uint8(0);

        dBE=uint8(0);
        d2BE=uint8(0);

        d2ZA=uint8(0);
        d2ZB=uint8(0);

        d4M64=uint64(0);
        d5M64=uint64(0);

        d5NZ=int16(0);

        d5E16=int16(0);

        d3AEI=int16(0);
        d4AEI=int16(0);
        d3BEI=int16(0);
        d4BEI=int16(0);
    end

    S=(AS~=BS);


    A_special=(AE==255);
    B_special=(BE==255);

    isAMnonzero=AM~=0;
    isBMnonzero=BM~=0;


    if(dA_special&&disAMnonzero)||(dB_special&&disBMnonzero)



    end

    disAMnonzero=isAMnonzero;
    disBMnonzero=isBMnonzero;


    A_denorm=(AE==0);
    B_denorm=(BE==0);
    A_zero=dA_denorm&&~disAMnonzero;
    B_zero=dB_denorm&&~disAMnonzero;


    eitherZero=A_zero||B_zero;

    if(dA_special||dB_special)



    end

    dA_special=A_special;
    dB_special=B_special;


    if(eitherZero||(A_denorm&&B_denorm))



    end




    AEI=int16(d2AE);
    d2AE=dAE;
    dAE=AE;

    ZA=count_leading_zeros24(dAM);

    d3AEI_next=AEI;
    if(dA_denorm)
        d3AM_next=shift_left(d2AM,d2ZA);
        d3AEI_next=AEI-int16(d2ZA)+1;
    else
        d3AM_next=bitset(d2AM,24);
    end
    d2ZA=ZA;

    dA_denorm=A_denorm;

    BEI=int16(d2BE);
    d2BE=dBE;
    dBE=BE;

    ZB=count_leading_zeros24(BM);

    d3BEI_next=BEI;
    if(dB_denorm)
        d3BM_next=shift_left(d2BM,d2ZB);
        d3BEI_next=BEI-int16(d2ZB)+1;
    else
        d3BM_next=bitset(d2BM,24);
    end
    d2ZB=ZB;

    dB_denorm=B_denorm;


    M64=uint64(d3AM)*uint64(d3BM);
    NZ=int16(16+(bitget(d4M64,48)==0));
    E16=int16(d4AEI)+int16(d4BEI)+int16(-110);
    [Eout,Mout]=normalize64_pipelined(d5M64,d5E16,d5NZ);

    d3AM=d3AM_next;
    d2AM=dAM;
    dAM=AM;
    d3BM=d3BM_next;
    d2BM=dBM;
    dBM=BM;
    d4AEI=d3AEI;
    d3AEI=d3AEI_next;
    d4BEI=d3BEI;
    d3BEI=d3BEI_next;
    d5M64=d4M64;
    d4M64=M64;
    d5E16=E16;
    d5NZ=NZ;

    Sout=d11S;
    d11S=d10S;
    d10S=d9S;
    d9S=d8S;
    d8S=d7S;
    d7S=d6S;
    d6S=d5S;
    d5S=d4S;
    d4S=d3S;
    d3S=d2S;
    d2S=dS;
    dS=S;
end


