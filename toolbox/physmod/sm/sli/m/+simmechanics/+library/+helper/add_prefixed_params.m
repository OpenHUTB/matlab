function add_prefixed_params(BlockInfoCache,maskParams,prefix)
    for idx=1:length(maskParams)
        maskParams(idx).VarName=[prefix,maskParams(idx).VarName];
    end
    BlockInfoCache.addMaskParameters(maskParams);
end