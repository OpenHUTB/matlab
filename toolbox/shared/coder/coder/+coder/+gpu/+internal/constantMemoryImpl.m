function constantMemoryImpl(var,externalUse)

%#codegen 
    coder.internal.allowHalfInputs;
    if(~coder.target('MATLAB'))
        coder.allowpcode('plain');

        coder.inline('never');

        coder.internal.prefer_const(externalUse);
        if eml_option('EnableGPU')
            coder.ceval('-preservearraydims','__gpu_constantMemory',var,externalUse);
        end
    end
end
