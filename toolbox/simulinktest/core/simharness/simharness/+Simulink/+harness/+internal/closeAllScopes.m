function closeAllScopes(bdHandle)




    if isempty(bdHandle)||~ishandle(bdHandle)
        Simulink.harness.internal.warn('Simulink:Harness:InvalidHandleToCloseScopes');
        return;
    end


    if Simulink.scopes.Util.isSLWebTimeScope
        figs=findobj(matlab.internal.webwindowmanager.instance.windowList,'Tag',"SIMULINK_SIMSCOPE_FIGURE");
    else
        figs=findall(0,'Type','figure','Tag','SIMULINK_SIMSCOPE_FIGURE');
    end
    if isempty(figs)
        return;
    end

    s=warning('off','Simulink:Libraries:MissingLibrary');
    sCleanup=onCleanup(@()warning(s));

    try


        allScopes=find_system(bdHandle,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'AllBlocks','on','type','block','BlockType','Scope');

        if~isempty(allScopes)
            close_system(allScopes);
        end
    catch ME
        Simulink.harness.internal.warn(ME);
    end

end
