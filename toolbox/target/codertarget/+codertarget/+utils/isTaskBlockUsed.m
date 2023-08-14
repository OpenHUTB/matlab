function ret=isTaskBlockUsed(hCS)













    ret=codertarget.utils.isESBEnabled(hCS)...
    &&locIsESBTaskBlkFound(hCS);
end



function res=locIsESBTaskBlkFound(hCS)


    res=~isempty(find_system(hCS.getModel,'LookUnderMasks','all',...
    'FirstResultOnly','on',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'FollowLinks','on','MaskType','ESB Task'));
end

