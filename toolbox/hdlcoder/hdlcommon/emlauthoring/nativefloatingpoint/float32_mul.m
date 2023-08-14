%#codegen
function[S,E,M]=float32_mul(AS,AE,AM,BS,BE,BM,Simp)


    coder.allowpcode('plain')

    S=(AS~=BS);
    if(Simp)
        [E,M]=float32_mul_nrm(AE,AM,BE,BM);
    else
        [E,M]=float32_mul_reg(AE,AM,BE,BM);
    end
end


function[E,M]=float32_mul_reg(AE,AM,BE,BM)

    A_zero=(AE==0)&&(AM==0);
    B_zero=(BE==0)&&(BM==0);

    if(AE==255)
        E=AE;

        M=uint32((AM~=0)||B_zero||((BE==255)&&(BM~=0)));
    else

        if(BE==255)
            E=BE;

            M=uint32((BM~=0)||A_zero||((AE==255)&&(AM~=0)));
        else



            if(A_zero||B_zero)
                E=uint8(0);
                M=uint32(0);
            else



                AEI=int16(AE);
                if(AE==0)
                    Z=count_leading_zeros24(AM);
                    AM=bitshift(AM,Z);
                    AEI=AEI-int16(Z)+1;
                else
                    AM=bitset(AM,24);
                end

                BEI=int16(BE);
                if(BE==0)
                    Z=count_leading_zeros24(BM);
                    BM=bitshift(BM,Z);
                    BEI=BEI-int16(Z)+1;
                else
                    BM=bitset(BM,24);
                end


                M64=uint64(AM)*uint64(BM);
                E16=int16(AEI)+int16(BEI)-int16(126);
                if(E16>255)
                    E=uint8(255);
                    M=uint32(0);
                else

                    if(bitget(M64,48))
                        M=uint32(bitshift(M64,-24));
                        TrOne=logical(bitget(M64,24));
                        TrSuf=bitand(M64,bitshift(1,23)-1)~=0;
                    else
                        M=uint32(bitshift(M64,-23));
                        TrOne=logical(bitget(M64,23));
                        TrSuf=bitand(M64,bitshift(1,22)-1)~=0;
                        E16=E16-1;
                    end

                    if(E16<=0)
                        E=uint8(0);
                        Sh=1-E16;
                        if(Sh>24)
                            M=uint32(0);
                        else
                            Mask=uint32(bitshift(1,Sh-1));
                            TrSuf=TrSuf||TrOne||(bitand(M,Mask-1)~=0);
                            TrOne=bitand(M,Mask)~=uint32(0);
                            M=bitshift(M,-int8(Sh));
                            [E,M]=float32_round(E,M,TrOne,TrSuf);
                        end
                    else
                        E=uint8(E16);
                        [E,M]=float32_round(E,M,TrOne,TrSuf);
                    end
                end
            end
        end
    end
end



function[E,M]=float32_mul_nrm(AE,AM,BE,BM)


    if(AE==0||BE==0)
        E=uint8(0);
        M=uint32(0);

    else

        AEI=int16(AE);
        AM=bitset(AM,24);
        BEI=int16(BE);
        BM=bitset(BM,24);



        M64=uint64(AM)*uint64(BM);
        E16=int16(AEI)+int16(BEI)-int16(126);






        if(bitget(M64,48))
            M=uint32(bitshift(M64,-24));
            TrOne=logical(bitget(M64,24));
            TrSuf=bitand(M64,bitshift(1,23)-1)~=0;
        else
            M=uint32(bitshift(M64,-23));
            TrOne=logical(bitget(M64,23));
            TrSuf=bitand(M64,bitshift(1,22)-1)~=0;
            E16=E16-1;
        end

        if(E16<0)
            E=uint8(0);M=uint32(0);
        elseif(E16==0)
            E=uint8(0);
            TrOne=logical(bitget(M,1));
            M=bitshift(M,-1);
        else
            E=uint8(E16);
        end

        [E,M]=float32_round_nrm(E,M,TrOne,TrSuf);
    end
end
