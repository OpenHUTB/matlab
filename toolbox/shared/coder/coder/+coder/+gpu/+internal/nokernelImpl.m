function nokernelImpl(externalUse)


%#codegen
    if(~coder.target('MATLAB'))
        coder.allowpcode('plain');
        coder.inline('never');
        coder.internal.prefer_const(externalUse);
        if(coder.target('MEX')||coder.target('Rtw')||coder.target('Sfun'))
            if coder.internal.targetLang('GPU')
                coder.ceval('-preservearraydims','__gpu_nokernel',externalUse);
            end
        end
    end
end
