%#codegen
function y=hdleml_const(cval)


    coder.allowpcode('plain')
    coder.internal.allowHalfInputs
    eml_prefer_const(cval);

    y=cval;
    eml_virtual_assign(y);

    for ii=coder.unroll(1:length(cval))
        y(ii)=cval(ii);
    end
