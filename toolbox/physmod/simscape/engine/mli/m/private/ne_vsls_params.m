function abstol=ne_vsls_params

    global vslsAbstol;
    if~isempty(vslsAbstol)
        abstol=vslsAbstol;
    else
        clear global vslsAbstol;
        abstol=-1;
    end
