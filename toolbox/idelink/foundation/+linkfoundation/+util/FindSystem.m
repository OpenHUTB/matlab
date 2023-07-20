function h=FindSystem(modelName,masktype)






    h=find_system(modelName,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'FollowLinks','on',...
    'LookUnderMasks','on',...
    'MaskType',masktype);

end
