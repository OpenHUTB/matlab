function[status,dscr]=OptimizeReductionsDependency(cs,name)

    dscr=[name,' is available only when instructionSetExtension is availabe'];

    if isa(cs,'Simulink.ConfigSet')
        config=cs;
    else
        config=cs.getConfigSet;
    end

    ISE=get_param(config,'InstructionSetExtensions');

    if ismember(ISE,'None')

        isERT=strcmp(get_param(config,'IsERTTarget'),'on');
        hw=config.getComponent('Hardware Implementation');
        deviceType=configset.internal.util.getTargetOrProdHardwareDevice(hw);
        [isAvailable,~]=RTW.getAvailableInstructionSets(deviceType,isERT);



        if isAvailable
            status=configset.internal.data.ParamStatus.ReadOnly;
        else
            status=configset.internal.data.ParamStatus.InAccessible;
        end

    else
        status=configset.internal.data.ParamStatus.Normal;
    end

end
