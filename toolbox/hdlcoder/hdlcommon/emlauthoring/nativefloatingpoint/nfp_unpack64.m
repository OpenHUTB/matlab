%#codegen
function[S,E,M]=nfp_unpack64(X)



    coder.allowpcode('plain');
    S=getmsb(X);
    E=bitsliceget(X,63,53);
    M=bitsliceget(X,52,1);
end
