%#codegen
function y=hdleml_subsub(u,v,outtp_ex,sumtp_ex,castInputsToSumType)


    coder.allowpcode('plain')
    eml_prefer_const(sumtp_ex,outtp_ex,castInputsToSumType);

    if isfloat(outtp_ex)
        y=-u-v;
    else
        z=fi(0,numerictype(sumtp_ex),fimath(sumtp_ex));
        zt=hdleml_sub_withcast(z,u,sumtp_ex,sumtp_ex,1);

        y=hdleml_sub_withcast(zt,v,outtp_ex,sumtp_ex,1);
    end
