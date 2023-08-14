function nonVirBus=hIsNonVirtualBus(h,hPort)%#ok









    nonVirBus=((get_param(hPort,'CompiledPortBusMode')==1)&&...
    strcmp(get_param(hPort,'CompiledBusType'),'NON_VIRTUAL_BUS'));



