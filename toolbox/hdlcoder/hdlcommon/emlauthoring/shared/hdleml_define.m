%#codegen
function y=hdleml_define(u)


    coder.allowpcode('plain')
    coder.internal.allowHalfInputs
    y=coder.nullcopy(u);
