function mdls=getObserverModelNamesInBD(topmdlH)







    obsMdlHdls=find_system(topmdlH,'IncludeCommented','On',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'BlockType','ObserverReference');
    obsMdls=arrayfun(@(mdl)get_param(mdl,'ObserverModelName'),obsMdlHdls,...
    'UniformOutput',false);

    mdls=unique(obsMdls);
end
