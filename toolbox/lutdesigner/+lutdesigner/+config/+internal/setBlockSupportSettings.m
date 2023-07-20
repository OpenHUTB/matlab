function setBlockSupportSettings(bss)

    lutdesigner.config.internal.validateBlockSupportSettings(bss);

    s=settings;
    if~s.hasGroup('lutdesigner')
        s.addGroup('lutdesigner','Hidden',true);
    end
    if~s.lutdesigner.hasGroup('lutfinder')
        s.lutdesigner.addGroup('lutfinder');
    end
    if~s.lutdesigner.lutfinder.hasSetting('CustomConfig')
        s.lutdesigner.lutfinder.addSetting('CustomConfig');
    end

    if s.hasGroup('lutdesigner')&&...
        s.lutdesigner.hasGroup('lutfinder')&&...
        s.lutdesigner.lutfinder.hasSetting('CustomConfig')
        s.lutdesigner.lutfinder.CustomConfig.PersonalValue=bss;
    end
end
