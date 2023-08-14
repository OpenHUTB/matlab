%#codegen
function y=hdleml_define_len(u,outLen)


    coder.allowpcode('plain')
    coder.internal.allowHalfInputs
    eml_prefer_const(outLen);


    y=coder.nullcopy(hdleml_init_len(u,outLen));

end

