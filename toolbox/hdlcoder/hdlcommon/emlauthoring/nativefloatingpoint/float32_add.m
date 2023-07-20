%#codegen
function[S,E,M]=float32_add(AS,AE,AM,BS,BE,BM,Simp)


    coder.allowpcode('plain')





    if((AE>BE)||((AE==BE)&&(AM>=BM)))
        CAE=AE;CAM=AM;
        CBE=BE;CBM=BM;
        S=AS;
    else
        CAE=BE;CAM=BM;
        CBE=AE;CBM=AM;
        S=BS;
    end

    if(Simp)
        if AS==BS
            [E,M]=float32add_sign_nrm(CAE,CAM,CBE,CBM);
        else
            [E,M]=float32sub_sign_nrm(CAE,CAM,CBE,CBM);
        end
    else
        if AS==BS
            [E,M]=float32add_sign(CAE,CAM,CBE,CBM);
        else
            [E,M]=float32sub_sign(CAE,CAM,CBE,CBM);
        end
    end
end



function[E,M]=float32add_sign(AE,AM,BE,BM)

    E=AE;
    N=AE-BE;
    TrOne=false;
    TrSuf=false;


    if(AE==255)||(N>24)
        M=AM;
    else


        if(AE~=0)
            AM=bitset(AM,24);
        else
            AE=AE+1;
        end

        if(BE~=0)
            BM=bitset(BM,24);
        else
            BE=BE+1;
        end


        N=AE-BE;

        if(N>0)
            Mask=bitshift(uint32(1),uint8(N-1));
            TrOne=uint32(bitand(BM,Mask))~=0;
            TrSuf=uint32(bitand(BM,Mask-1))~=0;
            BM=bitshift(BM,-int8(N));
        end


        M=AM+BM;

        if(bitget(M,25))
            TrSuf=TrSuf||TrOne;
            TrOne=logical(bitget(M,1));
            E=E+1;
            M=bitshift(M,-1);
        end

        [E,M]=float32_round(E,M,TrOne,TrSuf);
    end
end




function[E,M]=float32sub_sign(AE,AM,BE,BM)


    if(BE==255)
        E=BE;
        M=uint32(1);
    else
        E=AE;
        N=AE-BE;


        if(AE==255)||(N>25)
            M=AM;
        else

            TrOne=false;
            TrSuf=false;

            if(AE>0)
                AM=bitset(AM,24);
                if(BE>0)
                    BM=bitset(BM,24);
                else
                    N=N-1;
                end
            end


            if(N==1)&&(AM<=BM)
                AM=bitshift(AM,1);
                E=E-1;
                N=N-1;
            end


            if(N>0)
                Mask=bitshift(uint32(1),uint8(N));
                Tr=Mask-bitand(BM,Mask-1);

                BM=bitshift(BM,-int8(N));
                M=AM-BM;
                if(Tr~=Mask)
                    M=M-1;
                end

                Mask1=bitshift(Mask,-1);
                Mask2=bitshift(Mask,-2);
                Tr1=bitand(Tr,Mask1)~=0;
                Tr2=bitand(Tr,Mask2)~=0;
                Tr3=(Mask2>1)&&(bitand(Tr,Mask2-1)~=0);

                if(bitget(M,24))
                    TrOne=Tr1;
                    TrSuf=(Tr2||Tr3);
                else
                    M=bitor(bitshift(M,1),uint32(Tr1));
                    E=E-1;
                    TrOne=Tr2;
                    TrSuf=Tr3;
                end
            else
                M=AM-BM;
                if(M==0)
                    E=uint8(0);
                else
                    NZ=count_leading_zeros24(M);

                    if(NZ<E)
                        M=bitshift(M,NZ);
                        E=E-NZ;
                    else
                        if(E>0)
                            M=bitshift(M,uint8(E-1));
                            E=uint8(0);
                        end
                    end
                end

            end

            [E,M]=float32_round(E,M,TrOne,TrSuf);
        end
    end
end


function[E,M]=float32add_sign_nrm(AE,AM,BE,BM)

    E=AE;
    N=AE-BE;
    TrOne=false;
    TrSuf=false;


    if(N>24)||((BE==0)&&(BM==0))
        M=AM;
    else


        AM=bitset(AM,24);
        BM=bitset(BM,24);


        N=AE-BE;

        if(N>0)
            Mask=bitshift(uint32(1),uint8(N-1));
            TrOne=uint32(bitand(BM,Mask))~=0;
            TrSuf=uint32(bitand(BM,Mask-1))~=0;
            BM=bitshift(BM,-int8(N));
        end


        M=AM+BM;

        if(bitget(M,25))
            TrSuf=TrSuf||TrOne;
            TrOne=logical(bitget(M,1));
            E=E+1;
            M=bitshift(M,-1);
        end

        [E,M]=float32_round_nrm(E,M,TrOne,TrSuf);
    end
end



function[E,M]=float32sub_sign_nrm(AE,AM,BE,BM)

    E=AE;
    N=AE-BE;


    if(N>25)||((BE==0)&&(BM==0))
        M=AM;
    else

        TrOne=false;
        TrSuf=false;

        AM=bitset(AM,24);
        BM=bitset(BM,24);



        if(N==1)&&(AM<=BM)
            AM=bitshift(AM,1);
            E=E-1;
            N=N-1;
        end


        if(N>0)
            Mask=bitshift(uint32(1),uint8(N));
            Tr=Mask-bitand(BM,Mask-1);

            BM=bitshift(BM,-int8(N));
            M=AM-BM;
            if(Tr~=Mask)
                M=M-1;
            end

            Mask1=bitshift(Mask,-1);
            Mask2=bitshift(Mask,-2);
            Tr1=bitand(Tr,Mask1)~=0;
            Tr2=bitand(Tr,Mask2)~=0;
            Tr3=(Mask2>1)&&(bitand(Tr,Mask2-1)~=0);

            if(bitget(M,24))
                TrOne=Tr1;
                TrSuf=(Tr2||Tr3);
            else
                M=bitor(bitshift(M,1),uint32(Tr1));
                E=E-1;
                TrOne=Tr2;
                TrSuf=Tr3;
            end
        else
            M=AM-BM;





            NZ=count_leading_zeros24(M);

            if(NZ>=E)
                M=uint32(0);
                E=uint8(0);

            else
                M=bitshift(M,NZ);
                E=E-NZ;
            end
        end

        [E,M]=float32_round(E,M,TrOne,TrSuf);
    end
end
