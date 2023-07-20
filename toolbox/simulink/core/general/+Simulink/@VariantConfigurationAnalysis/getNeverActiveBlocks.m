function neverActiveBlocks=getNeverActiveBlocks(obj)











    obj.cacheData(true);


    blkHandles=obj.mBlkAnalysisInfo.getNeverActiveBlocks();
    blkHandles=unique(blkHandles);
    neverActiveBlocks=getfullname(blkHandles);
    if~iscell(neverActiveBlocks)
        neverActiveBlocks={neverActiveBlocks};
    end
    neverActiveBlocks=arrayfun(@(x)...
    Simulink.variant.utils.replaceNewLinesWithSpaces(x),neverActiveBlocks);
    neverActiveBlocks=neverActiveBlocks(:);
end


