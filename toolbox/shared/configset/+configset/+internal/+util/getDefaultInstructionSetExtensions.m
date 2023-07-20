function defaultSet=getDefaultInstructionSetExtensions(cs)
    if~isa(cs,'Simulink.ConfigSet')
        config=cs;
    else
        config=cs.getConfigSet;
    end
    isERT=strcmp(get_param(config,'IsERTTarget'),'on');

    hw=config.getComponent('Hardware Implementation');
    hwDeviceType=configset.internal.util.getTargetOrProdHardwareDevice(hw);
    default=RTW.getDefaultInstructionSetExtensions(hwDeviceType,isERT);
    if~isempty(default)
        if iscell(default)
            defaultSet=default{1};
        else
            defaultSet=default;
        end
    else
        defaultSet='None';
    end


    if configset.internal.util.enforceNoneInstructionSet(config)
        defaultSet='None';
    end
end
