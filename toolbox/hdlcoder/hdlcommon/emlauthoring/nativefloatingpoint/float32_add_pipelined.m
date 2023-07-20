%#codegen
function[S,E,M]=float32_add_pipelined(AS,AE,AM,BS,BE,BM)



    persistent dCAE dCAM dCBE dCBM
    if isempty(dCAE)
        dCAE=uint8(0);
        dCAM=uint32(0);
        dCBE=uint8(0);
        dCBM=uint32(0);
    end

    if((AE>BE)||((AE==BE)&&(AM>=BM)))
        CAE=AE;CAM=AM;
        CBE=BE;CBM=BM;
        S=AS;
    else
        CAE=BE;CAM=BM;
        CBE=AE;CBM=AM;
        S=BS;
    end

    if AS==BS
        [E,M]=float32add_sign_pipelined(dCAE,dCAM,dCBE,dCBM);
    else
        [E,M]=float32sub_sign_pipelined(dCAE,dCAM,dCBE,dCBM);
    end
    dCAE=CAE;
    dCAM=CAM;
    dCBE=CBE;
    dCBM=CBM;
end



function[Eout,Mout]=float32add_sign_pipelined(AE,AM,BE,BM)
    persistent dE dE2 dE3 dE4 dE5 dE6 dE7 dE8 dE9
    persistent dN dN2 dN3
    persistent dBE dBE2 dBE3
    persistent dAM dAM2 dAM3 dAM4
    persistent dBM dBM2 dBM2p dBM3 dBM3p dBM4
    persistent dM dM2 dM3 dM4 dM4p dM5
    persistent dTrOne dTrOne2 dTrOne3 dTrOne4 dTrSuf dTrSuf2 dTrSuf3 dTrSuf4
    persistent droundCond


    persistent dM6 dM7 dM8 dM9
    persistent dE10 dE11 dE12 dE13

    if isempty(dE)
        dE=uint8(0);
        dE2=uint8(0);
        dE3=uint8(0);
        dE4=uint8(0);
        dE5=uint8(0);
        dE6=uint8(0);
        dE7=uint8(0);
        dE8=uint8(0);
        dE9=uint8(0);

        dBE=uint8(0);
        dBE2=uint8(0);
        dBE3=uint8(0);

        dN=uint8(0);
        dN2=uint8(0);
        dN3=uint8(0);

        dAM=uint32(0);
        dAM2=uint32(0);
        dAM3=uint32(0);

        dBM=uint32(0);
        dBM2=uint32(0);
        dBM2p=uint32(0);
        dBM3=uint32(0);
        dBM3p=uint32(0);
        dBM4=uint32(0);

        dM=uint32(0);
        dM2=uint32(0);
        dM3=uint32(0);
        dM4=uint32(0);
        dM4p=uint32(0);
        dM5=uint32(0);


        dM6=uint32(0);
        dM7=uint32(0);
        dM8=uint32(0);
        dM9=uint32(0);

        dE10=uint8(0);
        dE11=uint8(0);
        dE12=uint8(0);
        dE13=uint8(0);

        dTrOne=false;
        dTrOne2=false;
        dTrOne3=false;
        dTrOne4=false;

        dTrSuf=false;
        dTrSuf2=false;
        dTrSuf3=false;
        dTrSuf4=false;

        droundCond=false;
    end

    E=AE;
    N=AE-BE;

    TrOne=false;
    TrSuf=false;












    dBM4_next=dBM3p;
    dBM2_next=dBM;
    N_next=dN;
    if(dN3>1||(dN3==1&&dBE3~=0))
        if(BE==0)
            N_next=N-1;
        else
            dBM2_next=bitset(BM,24);
        end

        Mask=shift_left(uint32(1),dN2-1);
        TrOne=uint32(bitand(dBM2,Mask))~=0;
        TrSuf=uint32(bitand(dBM2,Mask-1))~=0;
        dBM4_next=shift_right(dBM3,N);
    end
    dAM4=dAM3;
    dAM3=dAM2;
    dAM2=dAM;
    dAM=AM;


    dBM3=dBM2;
    dBM3p=dBM2p;
    dBM2p=dBM;
    dBM2=dBM2_next;
    dBM=BM;

    dN3=dN2;
    dN2=N_next;
    dN=N;
    dBE3=dBE2;
    dBE2=dBE;
    dBE=BE;

    M=dAM4+dBM4;
    NeedsShift=logical(bitget(dM,24));
    dBM4=dBM4_next;


    dM2_next=dM;
    dM=M;
    if N>0
        dM2_next=bitset(dM,24,0);
    else
        NeedsShift=(AE>0);
    end



    dTrSuf4_next=dTrSuf3;
    dTrOne4_next=dTrOne3;
    dM3_next=dM2;
    if(NeedsShift)
        dTrSuf4_next=dTrSuf3||dTrOne3;
        dTrOne4_next=logical(bitget(dM2,1));
        E=E+1;
        dM3_next=bitshift(dM2,-1);
    end
    dM2=dM2_next;

    dTrOne3=dTrOne2;
    dTrOne2=dTrOne;
    dTrOne=TrOne;

    dTrSuf3=dTrSuf2;
    dTrSuf2=dTrSuf;
    dTrSuf=TrSuf;

    dM4_next=dM3;
    roundCond=dTrOne4&&(bitget(dM3,1)||dTrSuf4);
    if(dE7==255)
        dM4_next=uint32(0);
        roundCond=false;
    end
    dM3=dM3_next;





    dM5_next=dM4;
    dE9_next=dE8;
    if(droundCond)
        dM5_next=dM4p;
        if(bitget(dM4p,24))
            dE9_next=dE8+1;
            dM5_next=bitset(dM4p,24,0);
        end
        dM4p=dM4_next+1;
    end
    droundCond=roundCond;

    Mout=dM9;
    dM9=dM8;
    dM8=dM7;
    dM7=dM6;
    dM6=dM5;


    dM5=dM5_next;
    dM4=dM4_next;



    Eout=dE13;
    dE13=dE12;
    dE12=dE11;
    dE11=dE10;
    dE10=dE9;


    dE9=dE9_next;
    dE8=dE7;
    dE7=dE6;
    dE6=dE5;
    dE5=dE4;
    dE4=dE3;
    dE3=dE2;
    dE2=dE;
    dE=E;


    dTrOne4=dTrOne4_next;
    dTrSuf4=dTrSuf4_next;

end




function[Eout,Mout]=float32sub_sign_pipelined(AE,AM,BE,BM)

    persistent dN d2N d3N d4N d5N
    persistent dBE
    persistent dAM d2AM d3AM d4AM
    persistent dBM d2BM d3BM d4BM
    persistent dE d2E d3E d4E d5E d6E d7E d8E d9E d10E d11E d12E d13E
    persistent d5M d6M d7M d8M d9M d10M d11M d12M d13M
    persistent d6Edecr
    persistent d7Mp d8Mp d9Mp d10Mp d12Mp
    persistent d7Ep d8Ep d9Ep d10Ep d12Ep
    persistent d6Mask d7Mask d7Mask2 d8Mask1 d8Mask2 d6Maskdecr d8Mask2decr
    persistent d4BM_preshift d5BM_preshift d6BM_preshift
    persistent d7Tr d8Tr
    persistent d9Tr1 d9Tr2 d9Tr3
    persistent d10TrOne d11TrOne d10TrSuf d11TrSuf
    persistent d12roundCond

    if isempty(dN)
        dN=uint8(0);
        d2N=uint8(0);
        d3N=uint8(0);
        d4N=uint8(0);
        d5N=uint8(0);

        dBE=uint8(0);

        dAM=uint32(0);
        d2AM=uint32(0);
        d3AM=uint32(0);
        d4AM=uint32(0);

        dBM=uint32(0);
        d2BM=uint32(0);
        d3BM=uint32(0);
        d4BM=uint32(0);

        dE=uint8(0);
        d2E=uint8(0);
        d3E=uint8(0);
        d4E=uint8(0);
        d5E=uint8(0);
        d6E=uint8(0);
        d7E=uint8(0);
        d8E=uint8(0);
        d9E=uint8(0);
        d10E=uint8(0);
        d11E=uint8(0);
        d12E=uint8(0);
        d13E=uint8(0);

        d5M=uint32(0);
        d6M=uint32(0);
        d7M=uint32(0);
        d8M=uint32(0);
        d9M=uint32(0);
        d10M=uint32(0);
        d11M=uint32(0);
        d12M=uint32(0);
        d13M=uint32(0);

        d6Edecr=uint8(0);

        d7Mp=uint32(0);
        d8Mp=uint32(0);
        d9Mp=uint32(0);
        d10Mp=uint32(0);
        d12Mp=uint32(0);

        d7Ep=uint8(0);
        d8Ep=uint8(0);
        d9Ep=uint8(0);
        d10Ep=uint8(0);
        d12Ep=uint8(0);

        d6Mask=uint32(0);
        d7Mask=uint32(0);
        d7Mask2=uint32(0);
        d8Mask1=uint32(0);
        d8Mask2=uint32(0);
        d6Maskdecr=uint32(0);
        d8Mask2decr=uint32(0);

        d4BM_preshift=uint32(0);
        d5BM_preshift=uint32(0);
        d6BM_preshift=uint32(0);

        d7Tr=uint32(0);
        d8Tr=uint32(0);

        d9Tr1=false;
        d9Tr2=false;
        d9Tr3=false;

        d10TrOne=false;
        d11TrOne=false;
        d10TrSuf=false;
        d11TrSuf=false;

        d12roundCond=false;
    end







    E=AE;
    N=AE-BE;








    TrOne=false;
    TrSuf=false;

    d2AM_next=dAM;
    if dE>0
        d2AM_next=bitset(dAM,24);
    end
    dAM=AM;

    d2N_next=dN;
    d2BM_next=dBM;
    if dE>0&&dBE>0
        d2BM_next=bitset(dBM,24);
    else
        d2N_next=dN-1;
    end
    dE=E;
    dN=N;
    dBE=BE;
    dBM=BM;

    d3N_next=d2N;
    d3AM_next=d2AM;
    d3E_next=d2E;
    if(d2N==1)&&(d2AM<=d2BM)
        d3AM_next=bitshift(d2AM,1);
        d3E_next=d2E-1;
        d3N_next=d2N-1;
    end
    d2E=dE;
    d2N=d2N_next;
    d2AM=d2AM_next;
    d2BM=d2BM_next;










    BM_preshift=d3BM;

    d4BM_next=d3BM;
    if(d3N>0)
        d4BM_next=shift_right(d3BM,d3N);
    end
    d3BM=d2BM;

    d3N=d3N_next;

    M=d4AM-d4BM;
    d4BM=d4BM_next;
    d4AM=d3AM;
    d3AM=d3AM_next;



    Edecr=d5E;
    d5E=d4E;
    d4E=d3E;
    d3E=d3E_next;

    d8M_next=d7M;
    d7Mp_next=d6M;
    d7Ep_next=d6E;
    d8Ep_next=d7Ep;
    d8Mp_next=d7Mp;
    d10M_next=d9M;
    d10E_next=d9E;
    d11M_interm=d10Mp;
    d11E_next=d10Ep;
    if(N>0)
        d11M_interm=d10M;
        d11E_next=d10E;

        Mask=shift_left(uint32(1),d5N);
        Tr=d6Mask-bitand(d6BM_preshift,d6Maskdecr);

        d6Maskdecr=Mask-1;

        if(d7Tr~=d7Mask)
            d8M_next=d7M-1;
        end

        Mask1=bitshift(d7Mask,-1);
        Mask2=bitshift(d6Mask,-2);
        Tr1=bitand(d8Tr,d8Mask1)~=0;
        Tr2=bitand(d8Tr,d8Mask2)~=0;
        Mask2decr=d7Mask2-1;
        Tr3=(d8Mask2>1)&&(bitand(d8Tr,d8Mask2decr)~=0);

        d7Mask=d6Mask;
        d6Mask=Mask;
        d8Mask1=Mask1;
        d8Mask2decr=Mask2decr;
        d8Mask2=d7Mask2;
        d7Mask2=Mask2;
        d8Tr=d7Tr;
        d7Tr=Tr;

        if(bitget(d9M,24))
            TrOne=d9Tr1;
            TrSuf=(d9Tr2||d9Tr3);
        else
            d10M_next=bitor(bitshift(d9M,1),uint32(d9Tr1));
            d10E_next=d9E-1;
            TrOne=d9Tr2;
            TrSuf=d9Tr3;
        end

        d9Tr1=Tr1;
        d9Tr2=Tr2;
        d9Tr3=Tr3;
    else





        NZ=count_leading_zeros24(d7M);

        if(NZ<d7E)
            d8Mp_next=shift_left(d7Mp,NZ);
            d8Ep_next=d7Ep-NZ;
        else
            if(d6E>0)
                d7Mp_next=shift_left(d6M,d6Edecr);
                d7Ep_next=uint8(0);
            end
        end

    end
    d9E=d8E;
    d8E=d7E;
    d7E=d6E;
    d6E=d5E;

    d10M=d10M_next;
    d10E=d10E_next;
    d10Mp=d9Mp;
    d9Mp=d8Mp;
    d8Mp=d8Mp_next;
    d10Ep=d9Ep;
    d9Ep=d8Ep;
    d8Ep=d8Ep_next;
    d7Mp=d7Mp_next;
    d7Ep=d7Ep_next;
    d9M=d8M;
    d8M=d8M_next;
    d7M=d6M;
    d6M=d5M;
    d5M=M;
    d6Edecr=Edecr;
    d6BM_preshift=d5BM_preshift;
    d5BM_preshift=d4BM_preshift;
    d4BM_preshift=BM_preshift;
    d5N=d4N;
    d4N=d3N;


    d11M_next=bitset(d11M_interm,24,0);


    d12Ep_next=d11E;
    d13M_next=d12M;
    d13E_next=d12E;

    roundCond=d11TrOne&&(bitget(d11M,1)||d11TrSuf);
    d11TrOne=d10TrOne;
    d10TrOne=TrOne;
    d11TrSuf=d10TrSuf;
    d10TrSuf=TrSuf;

    if(d12roundCond)
        d12Mp_interm=d11M+1;
        d12Mp_next=d12Mp_interm;
        if(bitget(d12Mp_interm,24))
            d12Ep_next=d11E+1;
            d12Mp_next=bitset(d12Mp_interm,24,0);
        end
        d12Mp=d12Mp_next;
        d12Ep=d12Ep_next;

        d13M_next=d12Mp;
        d13E_next=d12Ep;
    end
    d12roundCond=roundCond;
    Eout=d13E;
    Mout=d13M;
    d13M=d13M_next;
    d13E=d13E_next;
    d12M=d11M;
    d12E=d11E;
    d11M=d11M_next;
    d11E=d11E_next;


end