%#codegen
function y=hdleml_sum(u,v,outtp_ex)


    coder.allowpcode('plain')
    eml_prefer_const(outtp_ex);

    y=fi(u+v,numerictype(outtp_ex),fimath(outtp_ex));

