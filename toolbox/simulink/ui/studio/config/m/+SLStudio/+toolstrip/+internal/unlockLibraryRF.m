function unlockLibraryRF(cbinfo,action)
    bdType=get_param(cbinfo.model.handle,'BlockDiagramType');
    if(strcmpi(bdType,'library'))
        action.enabled=true;
    else
        action.enabled=false;
    end
    lockedLibrary=strcmpi(get_param(cbinfo.model.handle,'Lock'),'on');
    if lockedLibrary
        action.text='simulink_ui:studio:resources:lockedLibraryText';
        action.icon='locked';
        action.selected=true;
        if Simulink.harness.internal.hasActiveHarness(cbinfo.model.handle)
            action.enabled=false;
        end
    else
        action.text='simulink_ui:studio:resources:unlockedLibraryText';
        action.icon='unlocked';
        action.selected=false;
    end
end


