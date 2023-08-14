function generatemakecfg(h,sfcn)






    if nargin<1
        DAStudio.error('Simulink:tools:LCTErrorFirstFcnArgumentMustBeStruct');
    end

    try
        if(sfcn)
            emitter=legacycode.lct.gen.SFunMkCfgEmitter(h);
        else
            emitter=legacycode.lct.gen.UnifiedMkCfgEmitter(h);
        end
        emitter.emit();
    catch Me

        lctErrIdRadix=legacycode.lct.spec.Common.LctErrIdRadix;

        if strncmp(lctErrIdRadix,Me.identifier,numel(lctErrIdRadix))


            throwAsCaller(Me);
        else

            rethrow(Me);
        end
    end
