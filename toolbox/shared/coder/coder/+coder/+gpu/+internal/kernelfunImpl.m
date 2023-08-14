function kernelfunImpl(externalUse)
%#codegen


    if(~coder.target('MATLAB'))
        coder.allowpcode('plain');
        coder.internal.prefer_const(externalUse);
        coder.inline('never');
        if coder.gpu.internal.isGpuEnabled()&&~coder.internal.isConstantFolding
            coder.ceval('-preservearraydims','__gpu_kernelfun',externalUse);
        end
    end

end
