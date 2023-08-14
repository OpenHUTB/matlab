%#codegen
function[S,E,M]=float64_mul(AS,AE,AM,BS,BE,BM,Simp)


    coder.allowpcode('plain')


    S=(AS~=BS);
    if((AE>BE)||((AE==BE)&&(AM>=BM)))
        [E,M]=float64_mul_unsigned(AE,AM,BE,BM);
    else
        [E,M]=float64_mul_unsigned(BE,BM,AE,AM);
    end
end


function[E,M]=float64_mul_unsigned(AE,AM,BE,BM)


    B_zero=((BE==0)&&(BM==0));
    if(AE==2047)
        E=AE;
        M=bitor(AM,uint64(B_zero));
    else

        if((AE==0)||B_zero)
            E=uint16(0);
            M=uint64(0);
        else

            EE=int16(AE)+int16(BE)-int16(1022);


            AM=bitset(AM,53);
            if(BE~=0)
                BM=bitset(BM,53);
            else
                Z=count_leading_zeros64(BM)-11;
                BM=shift_left(BM,Z);
                EE=EE+1-int16(Z);
            end

            if(EE>2047)
                E=uint16(2047);
                M=uint64(0);
            else


                a0=hi(AM);
                a1=lo(AM);
                b0=hi(BM);
                b1=lo(BM);
                z0=a0*b0;
                z1=a1*b1;
                z2=(a0+a1)*(b0+b1)-(z0+z1);
                z3=hi(z1)+lo(z2);
                z4=lo(z0)+hi(z2)+hi(z3);
                c_lo=bitor(bitshift(lo(z3),32),lo(z1));
                c_hi=bitor(bitshift(hi(z0)+hi(z4),32),lo(z4));

                if(bitget(c_hi,42))
                    M=bitor(bitshift(c_hi,11),bitshift(c_lo,-53));
                    Tr1=logical(bitget(c_lo,53));
                    TrS=logical(bitand(c_lo,bitshift(uint64(1),52)-1));
                else
                    M=bitor(bitshift(c_hi,12),bitshift(c_lo,-52));
                    Tr1=logical(bitget(c_lo,52));
                    TrS=logical(bitand(c_lo,bitshift(uint64(1),51)-1));
                    EE=EE-1;
                end

                if(EE<=0)
                    Sh=1-EE;
                    if(Sh>53)
                        E=uint16(0);M=uint64(0);
                    else
                        Mask=shift_left(uint64(1),Sh-1);
                        Tr1=logical(bitand(M,Mask)~=0);
                        TrS=logical(TrS||(bitand(M,Mask-1)~=0));
                        M=shift_right(M,Sh);
                        EE=int16(0);
                    end
                end

                [E,M]=float64_round(uint16(EE),M,Tr1,TrS);
            end
        end
    end
end

function x=hi(a)
    x=uint64(bitshift(uint64(a),-32));
end

function x=lo(a)
    x=uint64(bitand(uint64(a),uint64(4294967295)));
end
