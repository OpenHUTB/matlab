%#codegen
function y=hdleml_bitsliceget(lidx,ridx,u)


    coder.allowpcode('plain')
    eml_prefer_const(lidx,ridx);

    y=bitsliceget(u,lidx,ridx);


