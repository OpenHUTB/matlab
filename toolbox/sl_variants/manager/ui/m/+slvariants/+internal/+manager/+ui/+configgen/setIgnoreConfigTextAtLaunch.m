function setIgnoreConfigTextAtLaunch(modelHandle)




    import slvariants.internal.manager.ui.config.VMgrConstants;

    modelName=getfullname(modelHandle);
    dlg=slvariants.internal.manager.ui.config.getConfigurationsDialog(modelName);
    configDlgSchema=dlg.getSource;

    configObjVarName=configDlgSchema.ConfigObjVarName;
    studioContainer=slvariants.internal.manager.core.getStudioContainer(modelHandle);
    vmgrApp=studioContainer.getContextObject().App;

    vmStudioHandle=slvariants.internal.manager.core.getStudio(modelHandle);
    toolStrip=vmStudioHandle.getToolStrip;

    currentTab=toolStrip.ActiveTab;

    if isequal(currentTab,VMgrConstants.AutoGenConfigTabId)
        vmgrApp.AutoGenConfigToolStripBroker.ExcludeVCD=configObjVarName;
        as=toolStrip.getActionService();
        as.refreshAction('autoGenConfigIgnoreConfigEditBoxAction');
    end


end
