%#codegen
function min_idx=hdleml_min_idxonly(u,v,u_idx,v_idx)





    coder.allowpcode('plain')


    if u<=v
        min_idx=u_idx;
    else
        min_idx=v_idx;
    end