function schema()



    schema.package('tlmg');










    if isempty(findtype('tlmgComponentEnvEnumT'))
        schema.EnumType('tlmgComponentEnvEnumT',...
        {'OSCI TLM2',...
        'Co-Ware SCML/TLM2'});
    end


    if isempty(findtype('tlmgComponentSocketMappingEnumT'))
        schema.EnumType('tlmgComponentSocketMappingEnumT',...
        {'One combined TLM socket for input data, output data, and control',...
        'Three separate TLM sockets for input data, output data, and control',...
        'Defined by imported IP-XACT file'});
    end

    if isempty(findtype('tlmgComponentAddressingEnumT'))
        schema.EnumType('tlmgComponentAddressingEnumT',...
        {'No memory map',...
        'Auto-generated memory map'});

    end

    if isempty(findtype('tlmgAddressSpecEnumT'))
        schema.EnumType('tlmgAddressSpecEnumT',...
        {'Single input and output address offsets',...
        'Individual input and output address offsets'});
    end


    if isempty(findtype('tlmgProcessingTypeEnumT'))
        schema.EnumType('tlmgProcessingTypeEnumT',...
        {'SystemC Thread',...
        'Callback Function',...
        'Periodic SystemC Thread'});
    end
















    if isempty(findtype('tlmgIrqPortTypeEnumT'))
        schema.EnumType('tlmgIrqPortTypeEnumT',...
        {'Create IRQ Port as an sc_signal',...
        'Create IRQ Port as a TLM socket'});
    end










    if isempty(findtype('tlmgLooselyTimedModeEnumT'))
        schema.EnumType('tlmgLooselyTimedModeEnumT',...
        {'Loosely Timed with No Temporal Decoupling',...
        'Loosely Timed with Temporal Decoupling and Payload Event Queue'});

    end


    if isempty(findtype('tlmgFixedPointStorageEnumT'))
        schema.EnumType('tlmgFixedPointStorageEnumT',...
        {'Use SystemC int data type for Simulink fixed point data type',...
        'Use SystemC fixed point data type for Simulink fixed point data type'});
    end



    if isempty(findtype('tlmgRuntimeTimingModeEnumT'))
        schema.EnumType('tlmgRuntimeTimingModeEnumT',...
        {'With timing',...
        'Without timing'});
    end
    if isempty(findtype('tlmgInputBufferTriggerModeEnumT'))
        schema.EnumType('tlmgInputBufferTriggerModeEnumT',...
        {'Automatic','Manual'});
    end
    if isempty(findtype('tlmgOutputBufferTriggerModeEnumT'))
        schema.EnumType('tlmgOutputBufferTriggerModeEnumT',...
        {'Automatic','Manual'});

    end

    if isempty(findtype('tlmgTargetOSSelectEnumT'))
        schema.EnumType('tlmgTargetOSSelectEnumT',...
        {'Current Host','Windows 64','Linux 64'});

    end



end
