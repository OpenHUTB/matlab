function checkProducts()












%#codegen

    coder.allowpcode('plain');

    coder.inline('always');


    coder.internal.errorIf(coder.target('HDL'),'optimlib_codegen:common:NoHDLSupport');


    coder.internal.errorIf(~coder.internal.isConst(eml_option('EnableGPU'))||eml_option('EnableGPU'),'optimlib_codegen:common:NoGPUSupport');


end

