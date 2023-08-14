%#codegen
function y=hdleml_delay(u,ic)


    coder.allowpcode('plain')
    coder.internal.allowHalfInputs
    eml_prefer_const(ic);

    persistent reg;
    if isempty(reg)
        reg=eml_const(ic);
    end
    y=reg;
    reg=u;

