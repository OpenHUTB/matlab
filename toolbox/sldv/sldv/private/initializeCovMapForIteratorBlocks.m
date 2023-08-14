function initializeCovMapForIteratorBlocks(aBlks,aBlkTypes,testcomp)








    iterIdx=find(strcmp(aBlkTypes,'WhileIterator')|strcmp(aBlkTypes,'ForIterator'));
    parents=get_param(aBlks(iterIdx),'Parent');
    parentsH=get_param(parents,'Handle');

    if~iscell(parentsH)
        parentsH={parentsH};
    end

    for i=1:length(parentsH)
        idx=iterIdx(i);
        iteratorTable('insert',parentsH{i},aBlks(idx));
    end






    if testcomp.analysisInfo.replacementInfo.replacementsApplied











        if Simulink.internal.useFindSystemVariantsMatchFilter()
            allMdlsInExtractedModelH=find_mdlrefs(testcomp.analysisInfo.extractedModelH,...
            'MatchFilter',@Simulink.match.activeVariants);
        else
            allMdlsInExtractedModelH=find_mdlrefs(testcomp.analysisInfo.extractedModelH,...
            'Variants','ActiveVariants');
        end
        for i=1:length(allMdlsInExtractedModelH)


            iteratorBlks_extractedModelH=find_system(allMdlsInExtractedModelH{i},...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'regexp','on','LookUnderMasks','all','FollowLinks','on',...
            'BlockType','ForIterator|WhileIterator');
            for j=1:length(iteratorBlks_extractedModelH)
                parentIterartorBlk=get_param(iteratorBlks_extractedModelH{j},'Parent');
                iteratorTable('insert',get_param(parentIterartorBlk,'Handle'),...
                get_param(iteratorBlks_extractedModelH{j},'Handle'));
            end
        end
    end
end
