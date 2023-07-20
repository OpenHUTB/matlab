function flag=checkEmbeddedSources(this)




    disallowed_source_list={'PN Sequence Generator','Sine Wave','HDL Counter',...
    'Counter Free-Running','Counter Limited','Ground'};
    disallowed_sources=strjoin(disallowed_source_list,'|');



    handle_blocks=find_system(this.m_DUT,'LookUnderMasks','all','FollowLinks','On','RegExp','On',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'Type','Block','BlockType',disallowed_sources);
    mask_blocks=find_system(this.m_DUT,'LookUnderMasks','all','FollowLinks','On','RegExp','On',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'Type','Block','MaskType',disallowed_sources);

    blocks=[mask_blocks;handle_blocks];
    flag=isempty(blocks);
    this.addCheckForEach(blocks,'warning','check-embedded-sources',0);
end
