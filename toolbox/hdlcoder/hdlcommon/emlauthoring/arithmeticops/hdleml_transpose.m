%#codegen
function y=hdleml_transpose(u,complexOut)


    coder.allowpcode('plain')
    coder.internal.allowHalfInputs
    eml_prefer_const(complexOut);

    if isreal(u)&&complexOut
        y=complex(u).';
    else
        y=u.';
    end


