function registerblock(hBlk)





    if~codertarget.resourcemanager.isregistered(hBlk,'AllBlocks','BlockHandles')
        codertarget.resourcemanager.set(hBlk,'AllBlocks','BlockHandles',[]);
    end
    blocks=codertarget.resourcemanager.get(hBlk,'AllBlocks','BlockHandles');

    blkh=get_param(hBlk,'Handle');
    if~ismember(blkh,blocks)
        blocks(end+1)=blkh;
        codertarget.resourcemanager.set(hBlk,'AllBlocks','BlockHandles',blocks);
    end
end