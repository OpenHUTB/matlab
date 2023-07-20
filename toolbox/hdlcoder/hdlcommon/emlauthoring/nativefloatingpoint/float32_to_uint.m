%#codegen
function u=float32_to_uint(S,E,M)


    coder.allowpcode('plain')

    u=uint32(0);
    if(float32_is_nan(E,M)||S||(E<127))
        return
    end

    E=E-127;

    if(E>=32)
        u=intmax('uint32');
        return
    end

    M=bitset(M,24);

    if(E>23)
        u=shift_left(M,E-23);
    else
        u=shift_right(M,23-E);
    end

end
