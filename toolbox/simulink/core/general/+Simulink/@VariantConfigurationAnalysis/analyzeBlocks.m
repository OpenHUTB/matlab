function analyzeBlocks(obj)




    obj.mBlkAnalysisInfo=sl_variants.analyzer.BlockAnalysisInfo(get_param(obj.ModelName,'Handle'));

    obj.mBlkAnalysisInfo.analyzeBlocks();
end


