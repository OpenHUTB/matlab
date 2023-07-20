%#codegen
function[S,E,M]=float64_unpack(X)


    coder.allowpcode('plain')

    M=bitand(X,uint64(4503599627370495));
    S=logical(bitget(X,64));
    E=uint16(bitand(bitshift(X,-52),2047));
end
