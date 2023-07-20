function[S,E,M]=uint_to_float32(x)
%#codegen


    coder.allowpcode('plain')

    S=0;
    if(x==0)
        E=uint8(0);M=uint32(0);
        return
    end

    NZ=count_leading_zeros32(x);

    E=126+32-NZ;
    T1=false;
    TS=false;

    if(NZ>=8)
        M=shift_left(x,NZ-8);
    else
        Sh=8-NZ;
        Mask=shift_left(uint32(1),Sh-1);
        Mask1=Mask-1;
        T1=(bitand(x,Mask)~=0);
        TS=(bitand(x,Mask1)~=0);
        M=shift_right(x,Sh);
    end

    M=bitset(M,24,0);

    if(T1&&(bitget(M,1)||TS))
        M=M+1;
        if(bitget(M,24))
            E=E+1;
            M=bitset(M,24,0);
        end
    end

end
