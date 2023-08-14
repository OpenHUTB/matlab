function updateGlobalWksName(bdHandle)







    import slvariants.internal.manager.ui.config.ConfigurationsDialogSchema

    if~slvariants.internal.manager.core.hasOpenVM(bdHandle)
        return;
    end

    vmStudioHandle=slvariants.internal.manager.core.getStudio(bdHandle);

    if isempty(vmStudioHandle)
        return;
    end

    modelName=getfullname(bdHandle);
    dlg=slvariants.internal.manager.ui.config.getConfigurationsDialog(modelName);
    configSchema=dlg.getSource;

    currConfigWorkspace=configSchema.ConfigCatalogCacheWrapper.ConfigWorkspace;

    ddName=get_param(bdHandle,'DataDictionary');

    configSchema.ConfigCatalogCacheWrapper.updateConfigWorkspace(ddName);

    globalWksName=configSchema.ConfigCatalogCacheWrapper.ConfigWorkspace;

    if strcmp(currConfigWorkspace,configSchema.SelectedConfig)
        configSchema.updateSelectedConfig(globalWksName);
        dlg.setWidgetValue('configNameLabelTag',globalWksName);

        dlg.updateToolTip('activateButtonTag',...
        message('Simulink:VariantManagerUI:HierarchyButtonActivateTooltip',globalWksName).getString());
    end
    configSchema.ConfigSSSrc.updateGlobalWksConfigName(globalWksName);

    configSchema.GlobalConfigSSSrc.Children(1).VarConfigName=globalWksName;
    configSchema.updateSpreadsheetRow(dlg,configSchema.GlobalConfigSSSrc.Children(1),'globalWSSSWidgetTag');
end


