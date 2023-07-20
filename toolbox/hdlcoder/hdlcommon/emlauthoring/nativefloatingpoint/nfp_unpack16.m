%#codegen
function[S,E,M]=nfp_unpack16(X)
    coder.allowpcode('plain');
    S=getmsb(X);
    E=bitsliceget(X,15,11);
    M=bitsliceget(X,10,1);
end
