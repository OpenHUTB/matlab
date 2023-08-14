function blk=getBlockName(h)




    blk='';

    if isempty(h.signalInfo)
        return;
    end

    len=h.signalInfo.blockPath_.getLength();
    if len>0
        blk=h.signalInfo.blockPath_.getBlock(len);
    end

end

