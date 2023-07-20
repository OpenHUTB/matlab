function blocks=getBlocksFromImplementation(this,implementation)













    blocks={};
    fn=this.getBlockTags;
    for ii=1:length(fn)
        entry=this.getBlock(fn{ii});
        if any(strcmpi(entry.Implementations,implementation))
            if isempty(blocks)
                blocks={entry.SimulinkPath};
            else
                blocks=cat(1,blocks,{entry.SimulinkPath});
            end
        end
    end

