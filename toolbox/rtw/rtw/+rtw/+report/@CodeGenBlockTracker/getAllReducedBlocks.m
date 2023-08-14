function value=getAllReducedBlocks(obj,buildDir)



    if(~obj.AllReducedBlocksCached)
        rtwTraceInfo=obj.getRTWTraceInfo(buildDir);
        obj.AllReducedBlocks=obj.getReducedBlocksFromRTWTraceInfo(rtwTraceInfo);
        obj.AllReducedBlocksCached=1;
    end
    value=obj.AllReducedBlocks;
end
