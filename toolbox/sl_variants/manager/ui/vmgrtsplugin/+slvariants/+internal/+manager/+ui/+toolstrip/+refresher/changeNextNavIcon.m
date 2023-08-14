function changeNextNavIcon(cbinfo,action)




    modelHandle=cbinfo.Context.Object.App.ModelHandle;
    navInfo=cbinfo.Context.Object.getNavigationInfo();

    switch navInfo
    case 'Simulink:VariantManagerUI:NavigateVariableUsageEntry'
        currNextIcon='navigateDown';
        action.description=getString(message('Simulink:VariantManagerUI:HierarchyButtonUsageNextTooltip'));
    case 'Simulink:VariantManagerUI:NavigateActiveEntry'
        currNextIcon='activeChoiceNext';
        action.description=getString(message('Simulink:VariantManagerUI:HierarchyButtonNextActive'));
    case 'Simulink:VariantManagerUI:NavigateInvalidEntry'
        currNextIcon='invalidNext';
        action.description=getString(message('Simulink:VariantManagerUI:HierarchyButtonNextInvalid'));
    end

    if~strcmp(navInfo,action.icon)
        action.icon=currNextIcon;
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
