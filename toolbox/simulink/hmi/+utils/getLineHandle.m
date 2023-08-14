

function lineHandle=getLineHandle(blockHandle,portNum)
    lineHandle=-1;
    portHs=get_param(blockHandle,'porthandles');
    if portNum>0&&portNum<=length(portHs.Outport)
        outPortH=portHs.Outport(portNum);
        lineHandle=get(outPortH,'Line');
    end
end
