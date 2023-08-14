function params=getTunableParameters(protectedModelName)




    [opts,fullName]=Simulink.ModelReference.ProtectedModel.getOptions(protectedModelName);
    if~slInternal('isProtectedModelFromThisSimulinkVersion',fullName)
        versionStr=slInternal('getProtectedModelVersion',fullName);
        protectedModelVersion=simulink_version(versionStr);
        if(protectedModelVersion<simulink_version('R2022a'))
            DAStudio.error('Simulink:protectedModel:NoAccessToTunableParameterForProtectedModelBeforeR22a',protectedModelName);
        end
    end
    params=opts.tunableParameters;


