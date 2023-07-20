function out=getBlockBySID(bhm,sid)






    blks=bhm.getBlocksBySID(sid);
    out=coder.descriptor.GraphicalBlock.empty;
    if~isempty(blks)
        out=blks(1);
    end
end