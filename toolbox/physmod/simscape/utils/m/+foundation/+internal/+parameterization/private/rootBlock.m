function blk=rootBlock(blk)




    blk=getfullname(blk);
    refBlock=get_param(blk,'ReferenceBlock');
    if~isempty(refBlock)
        blk=refBlock;
    end

end
