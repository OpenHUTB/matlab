function[sigH,isBus]=hGetBusSignalHierarchy(h,portHandle)%#ok





    if get_param(portHandle,'CompiledPortBusMode')==1
        sigH=get_param(portHandle,'SignalHierarchy');
        isBus=true;
    else

        sigH=[];
        isBus=false;
        return;
    end





