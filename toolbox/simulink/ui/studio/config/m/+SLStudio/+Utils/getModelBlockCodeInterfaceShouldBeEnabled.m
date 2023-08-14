function enabled=getModelBlockCodeInterfaceShouldBeEnabled(modelBlockHandle)


    simMode=get_param(modelBlockHandle,'SimulationMode');
    protectedModel=get_param(modelBlockHandle,'ProtectedModel');
    enabled=strcmp('off',protectedModel)&&...
    (strcmp('Software-in-the-loop (SIL)',simMode)||...
    strcmp('Processor-in-the-loop (PIL)',simMode));
end
