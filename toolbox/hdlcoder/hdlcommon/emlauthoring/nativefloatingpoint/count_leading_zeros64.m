%#codegen
function N=count_leading_zeros64(A)


    coder.allowpcode('plain')

    B=uint64(0);
    B=bitset(B,32);
    if(A<B)
        N=32+count_leading_zeros32(uint32(A));
    else
        N=count_leading_zeros32(uint32(bitshift(A,-32)));
    end
end
