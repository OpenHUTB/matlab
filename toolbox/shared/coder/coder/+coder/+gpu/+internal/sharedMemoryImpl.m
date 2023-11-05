function sharedMemoryImpl(symbol,externalUse,isCtxRowMajor,varargin)

%#codegen       

    if(~coder.target('MATLAB'))
        coder.allowpcode('plain');
        coder.internal.allowHalfInputs;

        coder.inline('never');

        coder.internal.prefer_const(externalUse);
        coder.internal.prefer_const(isCtxRowMajor);
        coder.internal.prefer_const(varargin);
        if coder.internal.targetLang('GPU')
            coder.internal.prefer_const(symbol)
            flag=coder.const(coder.gpu.validateSharedMemoryPragma(symbol,varargin{:}));
            if flag
                coder.ceval('-preservearraydims','__gpu_sharedMemory',symbol,varargin{:},isCtxRowMajor,externalUse);
            end
        end
    end
end
