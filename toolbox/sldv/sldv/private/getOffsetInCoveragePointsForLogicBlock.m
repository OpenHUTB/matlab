function out=getOffsetInCoveragePointsForLogicBlock(blockH,portIdx)




    out=0;
    pHs=get_param(blockH,'PortHandles');

    for i=1:portIdx-1
        out=out+get_param(pHs.Inport(i),'CompiledPortWidth');
    end
end
