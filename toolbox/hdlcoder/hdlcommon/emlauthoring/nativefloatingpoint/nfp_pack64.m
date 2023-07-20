%#codegen
function X=nfp_pack64(S,E,M)



    coder.allowpcode('plain');
    X=bitconcat(S,bitsliceget(E,11,1),M);
end
