function hideAllBdWindows(mdlname,sysname)














    windows=find_system(mdlname,'LookUnderMasks','on','FollowLinks','off',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'Regexp','on','BlockType','SubSystem|Scope','Open','on');
    for i=1:numel(windows)
        if~strcmp(windows{i},sysname)
            set_param(windows{i},'Open','off');
        end
    end

    if~strcmp(mdlname,sysname)
        set_param(mdlname,'Open','off');
    end

    h=get_param(mdlname,'Object');
    c=find(h,'-isa','Stateflow.Chart','Visible',true);
    for i=1:numel(c)
        if~strcmp(sysname,c(i).Path)
            c(i).Visible=false;
        end
    end

end
