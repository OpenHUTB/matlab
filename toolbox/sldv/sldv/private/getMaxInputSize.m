function maxSize=getMaxInputSize(blockH)



    pHs=get_param(blockH,'PortHandles');
    num=length(pHs.Inport);

    maxSize=1;
    for i=1:num
        portSize=get_param(pHs.Inport(i),'CompiledPortWidth');
        maxSize=max(maxSize,portSize);
    end
end
