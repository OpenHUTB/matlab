function unsetModelContentsCoverageIds(modelH)





    warning_state=warning('off');
    warnCleanup=onCleanup(@()warning(warning_state));


    allBlocks=find_system(modelH,'FollowLinks','on',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'LookUnderMasks','all',...
    'DisableCoverage','off');
    for idx=1:length(allBlocks)
        set_param(allBlocks(idx),'CoverageId',0);
    end