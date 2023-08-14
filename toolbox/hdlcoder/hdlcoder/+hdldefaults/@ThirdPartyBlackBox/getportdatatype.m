function blktype=getportdatatype(this,blk,is_inport)








    blktype=get_param(blk,'CompiledPortDataTypes');

    if is_inport
        blktype=blktype.Inport{:};
    else
        blktype=blktype.Outport{:};
    end
