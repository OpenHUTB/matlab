%#codegen
function max=hdleml_max(u,v)


    coder.allowpcode('plain')

    if(u>=v)
        max=u;
    else
        max=v;
    end


