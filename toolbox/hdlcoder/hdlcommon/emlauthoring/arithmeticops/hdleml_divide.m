%#codegen
function y=hdleml_divide(u,v,outtp_ex,need_outsat,divbyzero_outsat)





    coder.allowpcode('plain')
    coder.internal.allowHalfInputs
    eml_prefer_const(outtp_ex,need_outsat,divbyzero_outsat)

    if isfloat(outtp_ex)
        y=u/v;
    else
        nt_u=numerictype(u);
        nt_v=numerictype(v);

        nt_o=numerictype(outtp_ex);
        fm_o=fimath(outtp_ex);

        ut=fi(u,nt_u,fm_o);
        vt=fi(v,nt_v,fm_o);

        div_out=fi(ut/vt,nt_o,fm_o);



        if need_outsat
            if v==0
                y=divbyzero_outsat;
            else
                y=div_out;
            end
        else
            y=div_out;
        end
    end
