function inportSize=getInportSize(blockH,portIdx)










    pHs=get_param(blockH,'PortHandles');
    num=length(pHs.Inport);

    if portIdx<=num
        inportSize=get_param(pHs.Inport(portIdx),'CompiledPortWidth');
    else
        inportSize=0;
    end
end
