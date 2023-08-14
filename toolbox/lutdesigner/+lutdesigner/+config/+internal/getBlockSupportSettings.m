function bss=getBlockSupportSettings()

    s=settings;
    bss=[];
    if s.hasGroup('lutdesigner')&&...
        s.lutdesigner.hasGroup('lutfinder')&&...
        s.lutdesigner.lutfinder.hasSetting('CustomConfig')&&...
        s.lutdesigner.lutfinder.CustomConfig.hasPersonalValue()

        bss=s.lutdesigner.lutfinder.CustomConfig.PersonalValue;
    end
end
