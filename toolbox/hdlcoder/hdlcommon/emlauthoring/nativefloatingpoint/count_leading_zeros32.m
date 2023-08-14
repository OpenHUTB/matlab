%#codegen
function N=count_leading_zeros32(A)


    coder.allowpcode('plain')

    if(A<256)
        N=uint8(24)+count8(A);
    elseif(A<65536)
        N=uint8(16)+count8(bitshift(A,-8));
    elseif(A<16777216)
        N=uint8(8)+count8(bitshift(A,-16));
    else
        N=count8(bitshift(A,-24));
    end
end

function N=count8(A)

    if(bitget(A,8))
        N=uint8(0);
    elseif(bitget(A,7))
        N=uint8(1);
    elseif(bitget(A,6))
        N=uint8(2);
    elseif(bitget(A,5))
        N=uint8(3);
    elseif(bitget(A,4))
        N=uint8(4);
    elseif(bitget(A,3))
        N=uint8(5);
    elseif(bitget(A,2))
        N=uint8(6);
    elseif(bitget(A,1))
        N=uint8(7);
    else
        N=uint8(8);
    end
end
