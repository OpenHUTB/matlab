%#codegen
function y=hdleml_complexconjugate(u,outputEx,complexOut)


    coder.allowpcode('plain')
    coder.internal.allowHalfInputs
    eml_prefer_const(outputEx,complexOut);

    if isfloat(outputEx)
        y=conj(u);
    else
        if isreal(u)&&complexOut
            y=complex(u);
        else
            nt=numerictype(u);
            fm_ex=fimath(outputEx);

            y=conj(fi(u,nt,fm_ex));
        end
    end


