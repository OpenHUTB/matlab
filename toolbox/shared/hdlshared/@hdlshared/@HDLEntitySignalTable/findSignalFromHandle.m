function signals=findSignalFromHandle(this,portHandles)



































    if iscell(portHandles)
        portHandles=cell2mat(portHandles);
    end

    outSigs=find(this.PortHandles==portHandles);
    signals=outSigs(:)';
