function alwaysActiveBlocks=getAlwaysActiveBlocks(obj)











    obj.cacheData(true);


    blkHandles=obj.mBlkAnalysisInfo.getAlwaysActiveBlocks();
    blkHandles=unique(blkHandles);
    alwaysActiveBlocks=getfullname(blkHandles);
    if~iscell(alwaysActiveBlocks)
        alwaysActiveBlocks={alwaysActiveBlocks};
    end
    alwaysActiveBlocks=arrayfun(@(x)...
    Simulink.variant.utils.replaceNewLinesWithSpaces(x),alwaysActiveBlocks);

    alwaysActiveBlocks=alwaysActiveBlocks(:);
end


