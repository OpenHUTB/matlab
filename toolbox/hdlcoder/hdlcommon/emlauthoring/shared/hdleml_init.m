%#codegen
function y=hdleml_init(u)


    coder.allowpcode('plain')

    outLen=length(u);
    y=hdleml_init_len(u,outLen);
