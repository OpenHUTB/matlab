function blocks=getNonzeroResetBlocks(~,path,hierarchical)





    if nargin<3
        hierarchical=false;
    end
    blocks={};
    try
        blocks=findNonzeroUnitDelay(path,hierarchical,blocks);
        blocks=findNonzeroIntegerDelay(path,hierarchical,blocks);
        blocks=findNonzeroUnitDelayEnabled(path,hierarchical,blocks);
        blocks=findNonzeroUpsample(path,hierarchical,blocks);
        blocks=findNonzeroDownsample(path,hierarchical,blocks);
        blocks=findNonzeroRateTransition(path,hierarchical,blocks);
    catch %#ok<CTCH>
        return;
    end
end


function illegalBlocks=findIllegalBlocks(blocks,initValField)
    illegalBlocks={};
    for i=1:length(blocks)
        block=blocks{i};
        initVal=get_param(block,initValField);
        if str2double(initVal)~=0
            illegalBlocks{end+1}=block;%#ok<AGROW>
        end
    end
end


function blocks=findNonzeroUnitDelay(path,hierarchical,blocks)
    if hierarchical


        newBlocks=find_system(path,...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'LookUnderMasks','all',...
        'BlockType','UnitDelay');
    else
        newBlocks=find_system(path,'SearchDepth',1,'BlockType','UnitDelay');
    end
    newBlocks=findIllegalBlocks(newBlocks,'X0');
    blocks=[blocks,newBlocks];
end


function blocks=findNonzeroIntegerDelay(path,hierarchical,blocks)
    if hierarchical


        newBlocks=find_system(path,...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'LookUnderMasks','all',...
        'BlockType','Delay');
    else
        newBlocks=find_system(path,'SearchDepth',1,'BlockType','Delay');
    end
    newBlocks=findIllegalBlocks(newBlocks,'vinit');
    blocks=[blocks,newBlocks];
end


function blocks=findNonzeroUnitDelayEnabled(path,hierarchical,blocks)
    if hierarchical


        newBlocks=find_system(path,...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'LookUnderMasks','all',...
        'MaskType','Unit Delay Enabled');
    else
        newBlocks=find_system(path,'SearchDepth',1,'MaskType','Unit Delay Enabled');
    end
    newBlocks=findIllegalBlocks(newBlocks,'vinit');
    blocks=[blocks,newBlocks];
end


function blocks=findNonzeroUpsample(path,hierarchical,blocks)
    if hierarchical


        newBlocks=find_system(path,...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'LookUnderMasks','all',...
        'MaskType','Upsample');
    else
        newBlocks=find_system(path,'SearchDepth',1,'MaskType','Upsample');
    end
    newBlocks=findIllegalBlocks(newBlocks,'ic');
    blocks=[blocks,newBlocks];
end


function blocks=findNonzeroDownsample(path,hierarchical,blocks)
    if hierarchical


        newBlocks=find_system(path,...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'LookUnderMasks','all',...
        'MaskType','Downsample');
    else
        newBlocks=find_system(path,'SearchDepth',1,'MaskType','Downsample');
    end
    newBlocks=findIllegalBlocks(newBlocks,'ic');
    blocks=[blocks,newBlocks];
end


function blocks=findNonzeroRateTransition(path,hierarchical,blocks)
    if hierarchical


        newBlocks=find_system(path,...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'LookUnderMasks','all',...
        'BlockType','RateTransition');
    else
        newBlocks=find_system(path,'SearchDepth',1,'BlockType','RateTransition');
    end
    newBlocks=findIllegalBlocks(newBlocks,'X0');
    blocks=[blocks,newBlocks];
end


