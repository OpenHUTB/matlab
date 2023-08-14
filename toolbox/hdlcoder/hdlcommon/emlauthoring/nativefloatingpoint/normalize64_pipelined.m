%#codegen
function[E_out,M_out]=normalize64_pipelined(d5M64,d5E64,d5NZ)



    persistent d6EE d7EE d8EE d9EE d11E
    persistent d6Sh d7Sh
    persistent d6M64 d7M64 d8M64
    persistent d8Mask
    persistent d8M d9M d11M
    persistent d9TrOne d9TrSuf

    if isempty(d6EE)
        d6EE=int16(0);
        d7EE=uint8(0);
        d8EE=uint8(0);
        d9EE=uint8(0);
        d11E=uint8(0);

        d6Sh=int16(0);
        d7Sh=int16(0);

        d6M64=uint64(0);
        d7M64=uint64(0);
        d8M64=uint64(0);

        d8Mask=uint64(0);

        d8M=uint32(0);
        d9M=uint32(0);
        d11M=uint32(0);

        d9TrOne=false;
        d9TrSuf=false;
    end

    EE=int16(d5E64-d5NZ);








    Sh=int16(40-d5NZ);


    d7Sh_next=d6Sh;
    if(d6EE<=0)
        d7Sh_next=d6Sh-d6EE+1;







    end
    d6Sh=Sh;


    d7Sh_decr=d7Sh-1;


    Mask=shift_left(uint64(1),d7Sh_decr);
    TrOne=(bitand(d8M64,d8Mask)~=uint64(0));
    TrSuf=(bitand(d8M64,d8Mask-1)~=uint64(0));
    M=uint32(shift_right(d7M64,d7Sh));


    d8Mask=Mask;
    d8M64=d7M64;
    d7M64=d6M64;
    d6M64=d5M64;
    d7Sh=d7Sh_next;


    [d11E_next,d11M_next]=float32_round(d9EE,d9M,d9TrOne,d9TrSuf);
    d9M=bitset(d8M,24,0);
    d8M=M;
    d9EE=d8EE;
    d8EE=d7EE;
    d7EE=uint8(d6EE);
    d6EE=EE;
    d9TrOne=TrOne;
    d9TrSuf=TrSuf;

    E_out=d11E;
    M_out=d11M;
    d11E=d11E_next;
    d11M=d11M_next;
end
