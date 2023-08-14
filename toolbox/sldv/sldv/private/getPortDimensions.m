function portDim=getPortDimensions(blockH,inPortIdx,outPortIdx)



    pHs=get_param(blockH,'PortHandles');
    if inPortIdx>0
        num=length(pHs.Inport);
        ports=pHs.Inport;
        portIdx=inPortIdx;
    elseif outPortIdx>0
        num=length(pHs.Outport);
        ports=pHs.Outport;
        portIdx=outPortIdx;
    end

    if portIdx<=num
        portDim=get_param(ports(portIdx),'CompiledPortDimensions');
    else
        portDim=0;
    end
end
