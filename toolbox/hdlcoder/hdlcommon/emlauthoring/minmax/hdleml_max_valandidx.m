%#codegen
function[max,max_idx,is_greater]=hdleml_max_valandidx(u,v,u_idx,v_idx)


    coder.allowpcode('plain')

    if(u>=v)
        is_greater=true;
    else
        is_greater=false;
    end

    if is_greater==true
        max=u;
        max_idx=u_idx;
    else
        max=v;
        max_idx=v_idx;
    end
