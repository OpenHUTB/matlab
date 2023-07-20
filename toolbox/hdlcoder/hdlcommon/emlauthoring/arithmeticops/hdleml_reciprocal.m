%#codegen
function y=hdleml_reciprocal(u,onetp_ex,outtp_ex,need_outsat,divbyzero_outsat)







    coder.allowpcode('plain')
    eml_prefer_const(onetp_ex,outtp_ex,need_outsat,divbyzero_outsat);

    if isfloat(outtp_ex)
        y=1/u;
    else

        one=fi(1,numerictype(onetp_ex),fimath(onetp_ex));


        div_out=fi(one/u,numerictype(outtp_ex),fimath(outtp_ex));




        if need_outsat
            if u==0
                y=divbyzero_outsat;
            else
                y=div_out;
            end
        else
            y=div_out;
        end
    end
