%#codegen
function X=nfp_pack32(S,E,M)
    coder.allowpcode('plain');
    X=bitconcat(S,bitsliceget(E,8,1),M);
end
