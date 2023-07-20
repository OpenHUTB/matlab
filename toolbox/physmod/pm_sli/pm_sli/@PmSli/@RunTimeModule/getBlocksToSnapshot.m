function blocksInLibraryDB=getBlocksToSnapshot(this,mdl)














    getPmBlocks=pmsl_private('pmsl_pmblocksproducts');
    [allPmBlocks,topLevelPmBlocksFlags]=getPmBlocks(mdl);

    blocksInLibraryDB=allPmBlocks(topLevelPmBlocksFlags);

end


