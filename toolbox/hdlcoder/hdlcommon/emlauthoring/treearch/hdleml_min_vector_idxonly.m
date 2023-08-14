%#codegen
function y_idx=hdleml_min_vector_idxonly(u,u_idx)





    coder.allowpcode('plain')

    inputLen=length(u);
    eml_assert(inputLen==2,'Index only is only used in the last stage.');


    if(u(1)<=u(2))
        y_idx=u_idx(1);
    else
        y_idx=u_idx(2);
    end
