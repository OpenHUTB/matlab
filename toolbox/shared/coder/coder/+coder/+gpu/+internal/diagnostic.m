function diagnostic(msgID,varargin)

%#codegen

    if~coder.target('MATLAB')
        coder.allowpcode('plain');

        coder.inline('never');
        coder.internal.prefer_const(msgID);
        if coder.internal.targetLang('GPU')
            debugLevel=0;
            if nargin>1
                debugLevel=varargin{1};
            end
            coder.ceval('-preservearraydims','__gpu_diagnostic',msgID,debugLevel);
        end
    end
end
