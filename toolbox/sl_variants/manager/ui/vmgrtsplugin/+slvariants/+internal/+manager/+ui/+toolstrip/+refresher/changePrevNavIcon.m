function changePrevNavIcon(cbinfo,action)




    modelHandle=cbinfo.Context.Object.App.ModelHandle;
    navInfo=cbinfo.Context.Object.getNavigationInfo();

    switch navInfo
    case 'Simulink:VariantManagerUI:NavigateVariableUsageEntry'
        currPrevIcon='navigateUp';
        action.description=getString(message('Simulink:VariantManagerUI:HierarchyButtonUsagePrevTooltip'));
    case 'Simulink:VariantManagerUI:NavigateActiveEntry'
        currPrevIcon='activeChoicePrev';
        action.description=getString(message('Simulink:VariantManagerUI:HierarchyButtonPrevActive'));
    case 'Simulink:VariantManagerUI:NavigateInvalidEntry'
        currPrevIcon='invalidPrev';
        action.description=getString(message('Simulink:VariantManagerUI:HierarchyButtonPrevInvalid'));
    end

    if~strcmp(navInfo,action.icon)
        action.icon=currPrevIcon;
    end

    isHighlighted=slvariants.internal.manager.core.getIsAnyHierRowHighlighted(modelHandle);
    enable=slvariants.internal.manager.ui.toolstrip.isSelectedConfigActivatedConfig(modelHandle);
    inCompBrowserTab=slvariants.internal.manager.ui.compbrowser.SpreadSheetTabChange.isCompBrowserCurrentTab(modelHandle);





    if inCompBrowserTab||~enable||~isHighlighted&&strcmp(navInfo,'Simulink:VariantManagerUI:NavigateVariableUsageEntry')
        action.enabled=false;
    else
        action.enabled=true;
    end
end


