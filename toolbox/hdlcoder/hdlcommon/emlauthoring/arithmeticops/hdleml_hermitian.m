%#codegen
function y=hdleml_hermitian(u,outputEx,complexOut)


    coder.allowpcode('plain')
    eml_prefer_const(outputEx,complexOut);

    if isfloat(outputEx)
        y=u';
    else
        if isreal(u)&&complexOut
            y=complex(u');
        else
            nt=numerictype(u);
            fm=fimath(outputEx);
            y=fi(u,nt,fm)';
        end
    end

