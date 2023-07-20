%#codegen
function y=hdleml_bypass_register(u,bypass_enb,ic)


    coder.allowpcode('plain')
    coder.internal.allowHalfInputs
    eml_prefer_const(ic);

    fm=hdlfimath;
    one=fi(1,0,1,0,fm);


    persistent reg;
    if isempty(reg)
        reg=eml_const(ic);
    end

    if bypass_enb==one
        y=u;
    else
        y=reg;
    end

    reg=u;

