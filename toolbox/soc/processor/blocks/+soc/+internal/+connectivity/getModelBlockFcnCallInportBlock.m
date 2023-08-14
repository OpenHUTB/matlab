function blk=getModelBlockFcnCallInportBlock(port)




    import soc.internal.connectivity.*

    blk=[];
    if~isempty(port.DstBlock)
        mdlBlk=get_param(port.DstBlock,'ModelName');
        load_system(mdlBlk);
        inPorts=getSystemInputPorts(mdlBlk);
        idx=port.DstPort+1;
        blk=inPorts(idx);
    end
end