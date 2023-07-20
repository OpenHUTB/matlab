%#codegen
function min=hdleml_min(u,v)


    coder.allowpcode('plain')

    if(u<=v)
        min=u;
    else
        min=v;
    end


