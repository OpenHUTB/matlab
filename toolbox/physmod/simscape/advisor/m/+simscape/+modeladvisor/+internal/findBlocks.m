function blocks=findBlocks(system)






    blocks=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUndermasks','on','BlockType','SimscapeBlock','IsInternalSimscapePortConfigurationPreserved','true');
end