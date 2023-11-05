function includePtxImpl(varargin)%#codegen

    if~coder.target('MATLAB')
        coder.inline('never');
        coder.allowpcode('plain');
        if coder.internal.targetLang('GPU')
            coder.ceval('-preservearraydims','__gpu_include_ptx',varargin{:});
        end
    end
end
