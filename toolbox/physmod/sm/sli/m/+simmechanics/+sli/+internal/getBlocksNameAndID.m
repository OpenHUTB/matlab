function[blockNames,blockIDs]=getBlocksNameAndID(hModel)



    modelName=get_param(hModel,'name');



    subSystemBlockNames=pmsl_sanitizename(find_system(modelName,'FollowLinks','on',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'LookUnderMasks','all','BlockType','SubSystem'));
    smBlockNames=pmsl_sanitizename(find_system(modelName,'FollowLinks','on',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'LookUnderMasks','all','BlockType','SimscapeMultibodyBlock'));

    blockNames=[subSystemBlockNames;smBlockNames];

    blockIDs=Simulink.ID.getSID(blockNames);

end