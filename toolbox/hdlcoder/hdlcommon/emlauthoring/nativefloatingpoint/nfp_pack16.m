%#codegen
function X=nfp_pack16(S,E,M)
    coder.allowpcode('plain');
    X=bitconcat(S,bitsliceget(E,5,1),M);
end
