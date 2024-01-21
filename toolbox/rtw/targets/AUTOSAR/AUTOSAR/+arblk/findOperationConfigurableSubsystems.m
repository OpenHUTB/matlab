function blks=findOperationConfigurableSubsystems(aPath)

    blks=find_system(aPath,...
    'FollowLinks','on',...
    'MatchFilter',@Simulink.match.activeVariants,...
    'LookUnderMasks','on',...
    'Tag','AUTOSARConfigSubsystem');


