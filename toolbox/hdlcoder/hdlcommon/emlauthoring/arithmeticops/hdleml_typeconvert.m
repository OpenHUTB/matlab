%#codegen
function y=hdleml_typeconvert(u,outtp_ex)


    coder.allowpcode('plain')
    eml_prefer_const(outtp_ex);

    mode=1;
    y=hdleml_dtc(u,outtp_ex,mode);

end
