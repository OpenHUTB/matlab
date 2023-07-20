%#codegen
function[S,E,M]=float32_unpack(X)


    coder.allowpcode('plain')

    M=bitand(X,uint32(8388607));
    S=logical(bitget(X,32));
    E=uint8(bitand(bitshift(X,-23),255));
end
