function setEnableForNavigationDropDown(cbinfo,action)





    action.selectedItem=cbinfo.Context.Object.getNavigationInfo();
    modelHandle=cbinfo.Context.Object.getModelHandle();
    enable=slvariants.internal.manager.ui.toolstrip.isSelectedConfigActivatedConfig(modelHandle);
    if enable&&...
        ~slvariants.internal.manager.ui.compbrowser.SpreadSheetTabChange.isCompBrowserCurrentTab(modelHandle)

        action.enabled=true;
    else
        action.enabled=false;
    end
end
