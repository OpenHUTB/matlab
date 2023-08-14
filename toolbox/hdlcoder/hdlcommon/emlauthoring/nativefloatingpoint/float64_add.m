%#codegen
function[S,E,M]=float64_add(AS,AE,AM,BS,BE,BM,Simp)


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

    if(AS==BS)
        [E,M]=float64add_sign(CAE,CAM,CBE,CBM);
    else
        [E,M]=float64sub_sign(CAE,CAM,CBE,CBM);
    end
end



function[E,M]=float64add_sign(AE,AM,BE,BM)

    E=AE;
    Slide=AE-BE;
    TrOne=false;
    TrSuf=false;


    if(AE==2047)||(Slide>53)
        M=AM;
    else


        if(AE~=0)
            AM=bitset(AM,53);
            if(BE~=0)
                BM=bitset(BM,53);
            else
                Slide=Slide-1;
            end
        end



        if(Slide~=0)
            Mask=shift_left(uint64(1),Slide-1);
            TrOne=bitand(BM,Mask)~=0;
            TrSuf=bitand(BM,Mask-1)~=0;
            BM=shift_right(BM,Slide);
        end


        M=AM+BM;


        if(bitget(M,54))
            TrSuf=TrSuf||TrOne;
            TrOne=logical(bitget(M,1));
            E=E+1;
            M=bitshift(M,-1);
        end


        [E,M]=float64_round(E,M,TrOne,TrSuf);
    end
end




function[E,M]=float64sub_sign(AE,AM,BE,BM)


    if(BE==2047)
        E=BE;
        M=uint64(1);
    else
        E=AE;
        Slide=AE-BE;

        if(E==2047)||(Slide>53)
            M=AM;
        else

            TrOne=false;
            TrSuf=false;

            if(AE~=0)
                AM=bitset(AM,53);
                if(BE~=0)
                    BM=bitset(BM,53);
                else
                    Slide=Slide-1;
                end
            end

            if(Slide==1)&&(AM<BM)
                AM=bitshift(AM,1);
                E=E-1;
                Slide=Slide-1;
            end


            if(Slide>0)
                Mask=shift_left(uint64(1),Slide);
                Mask1=bitshift(Mask,-1);
                Tr=bitand(BM,Mask-1);
                NonZeroTr=Tr~=0;

                M=AM-shift_right(BM,Slide)-uint64(NonZeroTr);

                if(NonZeroTr)
                    Tr=Mask-Tr;
                end

                if(bitget(M,53)==0)
                    M=bitor(bitshift(M,1),uint64(bitand(Tr,Mask1)~=0));
                    E=E-1;
                    Tr=bitshift(Tr,1);
                end

                TrOne=bitand(Tr,Mask1)~=0;
                TrSuf=bitand(Tr,Mask1-1)~=0;

            else
                M=AM-BM;
                if(M==0)
                    E=uint16(0);
                else

                    NZ=count_leading_zeros64(M)-11;

                    if(NZ<E)
                        M=shift_left(M,NZ);
                        E=E-uint16(NZ);
                    else
                        if(E>0)
                            M=shift_left(M,E-1);
                            E=uint16(0);
                        end
                    end
                end

            end

            [E,M]=float64_round(E,M,TrOne,TrSuf);
        end
    end
end




