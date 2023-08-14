%#codegen
function y=hdleml_comparetovalue(u,mode,compval)


    coder.allowpcode('plain')
    coder.internal.allowHalfInputs
    eml_prefer_const(mode,compval);

    switch mode
    case 1
        y=(u==compval);
    case 2
        y=(u~=compval);
    case 3
        y=(u<=compval);
    case 4
        y=(u<compval);
    case 5
        y=(u>=compval);
    case 6
        y=(u>compval);
    otherwise
        eml_assert(0,'unsupported relation operation');
    end
