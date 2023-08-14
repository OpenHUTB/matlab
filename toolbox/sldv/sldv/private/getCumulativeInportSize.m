function cumulSize=getCumulativeInportSize(blockH,stIdx,endIdx)
















    pHs=get_param(blockH,'PortHandles');
    num=length(pHs.Inport);

    cumulSize=0;


    for i=stIdx:1:endIdx
        if i<=num
            cumulSize=get_param(pHs.Inport(i),'CompiledPortWidth')+...
            cumulSize;
        end
    end
end
