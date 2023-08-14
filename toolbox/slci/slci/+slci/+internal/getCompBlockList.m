function blk_list=getCompBlockList(sys)




    sorted_blks=slci.internal.getBlockList(sys);
    blk_list=slci.internal.replaceOrigRootWithSyntRootIOBlock(sorted_blks);
end

