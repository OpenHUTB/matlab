function blks=getLookupTableBlocks(model)





    tmpBlocks=[];






    ndBlocks=find_system(model,...
    'Findall','on',...
    'FollowLinks','on',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'LookUnderMasks','on',...
    'BlockType','Lookup_n-D');
    if~isempty(ndBlocks)
        for i=1:length(ndBlocks)
            blk=ndBlocks(i);
            remove_code=get_param(blk,'RemoveProtectionInput');
            if strcmp(remove_code,'off')
                tmpBlocks{end+1}=blk;
            end
        end
    end






    plBlocks=find_system(model,...
    'Findall','on',...
    'FollowLinks','on',...
    'LookUnderMasks','on',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'BlockType','PreLookup');
    if~isempty(plBlocks)
        for i=1:length(plBlocks)
            blk=plBlocks(i);
            remove_code=get_param(blk,'RemoveProtectionInput');
            if strcmp(remove_code,'off')
                tmpBlocks{end+1}=blk;
            end
        end
    end






    plBlocks=find_system(model,...
    'Findall','on',...
    'FollowLinks','on',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'LookUnderMasks','on',...
    'BlockType','Interpolation_n-D');

    if~isempty(plBlocks)
        for i=1:length(plBlocks)
            blk=plBlocks(i);
            check_code=get_param(blk,'RemoveProtectionIndex');
            if strcmp(check_code,'off')
                tmpBlocks{end+1}=blk;
            end
        end
    end






    plBlocks=find_system(model,...
    'Findall','on',...
    'FollowLinks','on',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'LookUnderMasks','on',...
    'BlockType','LookupNDDirect');

    if~isempty(plBlocks)
        for i=1:length(plBlocks)
            blk=plBlocks(i);
            check_code=get_param(blk,'RemoveProtectionInput');
            if strcmp(check_code,'off')
                tmpBlocks{end+1}=blk;
            end
        end
    end


    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(model);
    tmpBlocks=mdladvObj.filterResultWithExclusion(tmpBlocks);

    blks=tmpBlocks;
