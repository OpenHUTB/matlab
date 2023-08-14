function diffBlocks=getBlockDifferences(obj)











    obj.cacheData(true);


    blkHandles=obj.mBlkAnalysisInfo.getPartiallyActiveBlocks();
    blkHandles=unique(blkHandles);
    diffBlocks=getfullname(blkHandles);
    if~iscell(diffBlocks)
        diffBlocks={diffBlocks};
    end
    diffBlocks=arrayfun(@(x)...
    Simulink.variant.utils.replaceNewLinesWithSpaces(x),diffBlocks);
    diffBlocks=diffBlocks(:);
end


