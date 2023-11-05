function noKernelRegion()

%#codegen
    if~coder.target('MATLAB')
        coder.allowpcode('plain');
        coder.inline('never');
        if(coder.target('MEX')||coder.target('Rtw')||coder.target('Sfun'))
            if coder.internal.targetLang('GPU')
                coder.ceval('-preservearraydims','__gpu_noKernelRegion');
            end
        end
    end
end
