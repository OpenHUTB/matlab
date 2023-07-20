function deadBlocks=filterAtomicBlks(obj,sliceMdl,groups,deadBlocks,post)






    import Transform.*;

    if obj.options.InlineOptions.Libraries
        updateWaitBar(obj,'Sldv:ModelSlicer:ModelSlicer:BreakingLibraryLinks');
        breakLibraryLinks(sliceMdl);
    end

    transformRules=obj.transforms;
    for i=1:length(transformRules)
        transformRules(i).filterBlocksInAtomicGroup(groups,obj.options);
    end
    for i=1:length(post)
        post(i).filterBlocksInAtomicGroup(groups,obj.options);
    end
end
