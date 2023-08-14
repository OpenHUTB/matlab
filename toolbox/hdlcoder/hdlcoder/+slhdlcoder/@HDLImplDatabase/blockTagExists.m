function value=blockTagExists(this,slBlockPath)





    blk=this.getBlock(slBlockPath);
    value=~isempty(blk);

