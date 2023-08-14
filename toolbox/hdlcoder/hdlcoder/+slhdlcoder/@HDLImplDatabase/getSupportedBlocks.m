function blocks=getSupportedBlocks(this)







    if isempty(this.BlockDB)
        error(message('hdlcoder:engine:invalidDatabase','getSupportedBlocks'));
    end

    fn=this.getBlockTags;
    blocks=cell(length(fn),1);
    for ii=1:length(fn)
        blk=this.getBlock(fn{ii});
        blocks{ii}=blk.SimulinkPath;
    end

    blocks=sort(blocks);
