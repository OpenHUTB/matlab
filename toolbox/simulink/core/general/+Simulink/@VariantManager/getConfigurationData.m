function vcdoObj=getConfigurationData(modelName)














    [isInstalled,err]=slvariants.internal.utils.getVMgrInstallInfo('Simulink.VariantManager.getConfigurationData');
    if~isInstalled
        throwAsCaller(err);
    end

    try
        vcdoObj=Simulink.VariantConfigurationData.getFor(modelName);
    catch ME
        throwAsCaller(ME);
    end
end
