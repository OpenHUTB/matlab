function hideAllBdScopes(mdlname,sysname)








    windows=find_system(mdlname,'LookUnderMasks','on','FollowLinks','off',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'Regexp','on','BlockType','Scope','Open','on');
    for i=1:numel(windows)
        if~strcmp(windows{i},sysname)
            set_param(windows{i},'Open','off');
        end
    end

end
