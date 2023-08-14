%#codegen
function hfi=hdleml_fi(data,T,F)












    coder.allowpcode('plain')

    hfi=eml_cast(data,T,F);
