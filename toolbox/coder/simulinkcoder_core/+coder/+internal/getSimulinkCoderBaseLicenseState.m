function[result,msg]=getSimulinkCoderBaseLicenseState(operation)



    result=coder.internal.getSimulinkCoderLicenseState(operation)||...
    coder.oneclick.Utils.isRTTInstalledOriginal;
    if slfeature('UnifiedTargetHardwareSelection')
        result=result||coder.oneclick.Utils.isAnySimulinkTargetInstalled;
    end
    msg='';
end
