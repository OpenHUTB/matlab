function calcInternalRanges(model,runObj)








    if~runObj.hasDerivedRangeResults
        return;
    end
    allResults=runObj.getResults();
    registeredBlockAndObjectPairs={...
    {'Product',@Simulink.FixedPointAutoscaler.InternalRangeProduct}...
    ,{'Bias',@Simulink.FixedPointAutoscaler.InternalRangeBias}...
    ,{'Gain',@Simulink.FixedPointAutoscaler.InternalRangeGain}...
    ,{'DotProduct',@Simulink.FixedPointAutoscaler.InternalRangeDotProduct}...
    ,{'MinMax',@Simulink.FixedPointAutoscaler.InternalRangeMinMax}...
    ,{'Math',@Simulink.FixedPointAutoscaler.InternalRangeMath}...
    ,{'Sum',@Simulink.FixedPointAutoscaler.InternalRangeSum}...
    };

    if Simulink.internal.useFindSystemVariantsMatchFilter()
        findBlocksOfTypeFunc=@(mdl,type)find_system(mdl,'FollowLinks','on',...
        'LookUnderMasks','all','MatchFilter',@Simulink.match.activeVariants,...
        'BlockType',type);
    else
        findBlocksOfTypeFunc=@(mdl,type)find_system(mdl,'FollowLinks','on',...
        'LookUnderMasks','all','Variants','ActiveVariants',...
        'BlockType',type);
    end
    for pairIdx=1:size(registeredBlockAndObjectPairs,2)
        pair=registeredBlockAndObjectPairs{pairIdx};

        blocks=findBlocksOfTypeFunc(model,pair{1});
        blockObjs=get_param(blocks,'Object');


        isActive=cellfun(@(x)x.CompiledIsActive,blockObjs,...
        'UniformOutput',false);
        indices=cellfun(@(x)strcmpi(x,'on'),isActive);
        blockObjs=blockObjs(indices);
        runObjCell=cell(size(blockObjs));
        runObjCell(:)={runObj};
        allResultsCell=cell(size(blockObjs));
        allResultsCell(:)={allResults};
        classCell=cellfun(pair{2},blockObjs,runObjCell,allResultsCell,...
        'UniformOutput',false);
        cellfun(@calcInternalRange,classCell);
    end


