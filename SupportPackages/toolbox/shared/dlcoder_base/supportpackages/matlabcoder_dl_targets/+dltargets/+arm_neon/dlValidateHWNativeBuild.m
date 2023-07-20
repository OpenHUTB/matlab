function dlValidateHWNativeBuild(codeConfigObj)





    if isempty(codeConfigObj.Hardware)

        if~(codeConfigObj.GenCodeOnly)
            warning(message('gpucoder:cnnconfig:MissingHardwareConfigurationObject'));
            codeConfigObj.GenCodeOnly=true;
        end
    end
    if isempty(codeConfigObj.DeepLearningConfig.ArmArchitecture)
        error(message('gpucoder:cnnconfig:MissingArmArchitecture'));
    end
end
