%#codegen
function y=hdleml_logicalop(u,v,mode)


    coder.allowpcode('plain')
    eml_prefer_const(mode);

    switch mode
    case 1
        y=and(u,v);
    case 2
        y=or(u,v);
    case 3
        y=~and(u,v);
    case 4
        y=~or(u,v);
    case 5
        y=xor(u,v);
    case 6
        y=not(u);
    otherwise

        y=(u==v);
    end
