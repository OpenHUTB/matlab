%#codegen
function y=hdleml_relop(mode,u,v)


    coder.allowpcode('plain')
    coder.internal.allowHalfInputs
    eml_prefer_const(mode);

    switch mode
    case 1
        y=(u==v);
    case 2
        y=(u~=v);
    case 3
        y=(u<=v);
    case 4
        y=(u<v);
    case 5
        y=(u>=v);
    case 6
        y=(u>v);
    otherwise
        eml_assert(0,'unsupported relation operation');
    end
