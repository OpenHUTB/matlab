function persistentMemoryImpl(var,externalUse)




%#codegen
    if(~coder.target('MATLAB'))
        coder.allowpcode('plain');


        coder.inline('never');

        coder.internal.prefer_const(externalUse);
        if coder.gpu.internal.isGpuPersistentSupported()
            if isobject(var)
                coder.internal.compileWarning('gpucoder:common:PersistentMemMCOSNotSupported');
            else
                coder.ceval('-preservearraydims','__gpu_persistentMemory',var,externalUse);
            end
        end
    end
end
