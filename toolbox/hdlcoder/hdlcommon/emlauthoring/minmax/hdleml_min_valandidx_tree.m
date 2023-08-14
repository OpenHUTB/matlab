%#codegen
function[min,min_idx]=hdleml_min_valandidx_tree(u,v,u_idx,v_idx)


    coder.allowpcode('plain')

    if(u<=v)
        is_less=true;
    else
        is_less=false;
    end

    if is_less==true
        min=u;
        min_idx=u_idx;
    else
        min=v;
        min_idx=v_idx;
    end
