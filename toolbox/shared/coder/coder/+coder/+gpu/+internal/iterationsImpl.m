function iterationsImpl(externalUse,iterations)


%#codegen
    eml_invariant(isscalar(iterations)&&isnumeric(iterations),...
    'gpucoder:common:IterationsPragmaInputScalarNumeric');

    eml_invariant(iterations==floor(iterations),...
    'gpucoder:common:IterationsPragmaInputIntegral');

    if(~coder.target('MATLAB'))
        coder.allowpcode('plain');
        coder.inline('never');
        coder.internal.prefer_const(externalUse);
        if(coder.target('MEX')||coder.target('Rtw')||coder.target('Sfun'))
            if coder.internal.targetLang('GPU')
                coder.ceval('-preservearraydims','__gpu_iterations',externalUse,iterations);
            end
        end
    end
end
