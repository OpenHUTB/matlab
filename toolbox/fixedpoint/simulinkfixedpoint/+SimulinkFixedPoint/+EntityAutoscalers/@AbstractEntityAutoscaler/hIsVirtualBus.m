function virBus=hIsVirtualBus(h,hPort)%#ok<INUSL>






    virBus=((get_param(hPort,'CompiledPortBusMode')==1)&&...
    strcmp(get_param(hPort,'CompiledBusType'),'VIRTUAL_BUS'));



