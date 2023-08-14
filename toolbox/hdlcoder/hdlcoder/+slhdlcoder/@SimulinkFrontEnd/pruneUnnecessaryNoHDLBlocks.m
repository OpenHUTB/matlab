function prunedCompiledBlockList=pruneUnnecessaryNoHDLBlocks(~,compiledBlockList)





    blockTypeList=get_param(compiledBlockList,'BlockType');

    if(~iscell(blockTypeList))
        blockTypeList={blockTypeList};
    end


    noOpBlocks={'ToAsyncQueueBlock','Scope','AlgorithmDescriptor',...
    'AlgorithmDescriptorDelegate'};

    prunedIndices=cellfun(@(x)~any(strcmpi(x,noOpBlocks)),blockTypeList);

    objs=get_param(compiledBlockList,'Object');

    if(~iscell(objs))
        objs={objs};
    end




    prunedIndices=prunedIndices&~cellfun(@(x)x.isSynthesized&&strcmp(x.getSyntReason,'SL_SYNT_BLK_REASON_BS_VIRTUALIZATION'),objs);

    prunedCompiledBlockList=compiledBlockList(prunedIndices);
end