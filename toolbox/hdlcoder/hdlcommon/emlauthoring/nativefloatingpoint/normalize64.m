%#codegen
function[E,M]=normalize64(M64,E64,NZ,imprecise)


    coder.allowpcode('plain')

    EE=int16(E64-NZ);

    if(EE>=255)
        E=uint8(255);
        M=uint32(0);
        return
    end


    Sh=int16(40-NZ);


    if(EE<=0)
        Sh=Sh-EE+1;
        E=uint8(0);
        if(Sh>48)
            M=uint32(0);
            return
        end
    end


    Mask=shift_left(uint64(1),Sh-1);
    Tr1=(bitand(M64,Mask)~=uint64(0));
    TrS=imprecise||(bitand(M64,Mask-1)~=uint64(0));
    M=bitset(uint32(shift_right(M64,Sh)),24,0);
    E=uint8(EE);

    if(Tr1&&(bitget(M,1)||TrS))
        M=M+1;
        if(bitget(M,24))
            E=E+1;
            M=bitset(M,24,0);
        end
    end
end
