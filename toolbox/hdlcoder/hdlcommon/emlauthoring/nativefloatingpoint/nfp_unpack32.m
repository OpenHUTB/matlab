%#codegen
function[S,E,M]=nfp_unpack32(X)
    coder.allowpcode('plain');
    S=getmsb(X);
    E=bitsliceget(X,31,24);
    M=bitsliceget(X,23,1);
end
