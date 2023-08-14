%#codegen
function max_idx=hdleml_max_idxonly(u,v,u_idx,v_idx)





    coder.allowpcode('plain')


    if u>=v
        max_idx=u_idx;
    else
        max_idx=v_idx;
    end