function bldParams=emcCantWriteCodeDescriptorWarning(bldParams)




    if isfield(bldParams,'emittedCodeDescriptorWarning')&&bldParams.emittedCodeDescriptorWarning
        return
    end
    bldParams.emittedCodeDescriptorWarning=true;
    ccwarningid('Coder:common:CodeDescriptorAlreadyExists');
