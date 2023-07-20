%#codegen
function i=float32_to_int(S,E,M)


    coder.allowpcode('plain')

    i=int32(0);

    if(float32_is_nan(E,M)||(E<127))
        return
    end

    E=E-127;

    if(E>=31)
        if(S)
            i=intmin('int32');
        else
            i=intmax('int32');
        end
        return
    end

    M=bitset(M,24);

    if(E>23)
        i=int32(shift_left(M,E-23));
    else
        i=int32(shift_right(M,23-E));
    end

    if(S)
        i=-i;
    end

end
