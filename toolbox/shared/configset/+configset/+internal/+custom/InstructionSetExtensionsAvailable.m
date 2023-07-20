function[status,dscr]=InstructionSetExtensionsAvailable(cs,name)



    dscr=[name,' is available only when instructionSetArchitecture for the given Hardware is registered'];

    status=configset.internal.data.ParamStatus.InAccessible;

    if isa(cs,'Simulink.ConfigSet')
        config=cs;
    else
        config=cs.getConfigSet;
    end

    isERT=strcmp(get_param(config,'IsERTTarget'),'on');
    hw=config.getComponent('Hardware Implementation');
    deviceType=configset.internal.util.getTargetOrProdHardwareDevice(hw);

    [isAvailable,~]=RTW.getAvailableInstructionSets(deviceType,isERT);

    if isAvailable
        status=configset.internal.data.ParamStatus.Normal;
    end

end

