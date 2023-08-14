function activateModelForUI(dlg,configName)






    configDlgSchema=dlg.getSource;
    updateRowStyling(dlg,configDlgSchema);

    modelName=configDlgSchema.BDName;
    modelH=get_param(modelName,'Handle');
    slvariants.internal.manager.core.activateModelForUI(modelH,configName);


    slvariants.internal.manager.ui.compbrowser.CompBrowserSSSource.resetCompBrowserSource(dlg);


    configDlgSchema.CtrlVarSSSrc.clearHighlightForAllCtrlVar(dlg);

    slvariants.internal.manager.ui.config.setEnableForNavButtonVarUsage(modelH);



    vmStudioHandle=slvariants.internal.manager.core.getStudio(modelH);
    ssModelHierComp=vmStudioHandle.getComponent('GLUE2:SpreadSheet',...
    message('Simulink:VariantManagerUI:HierarchyTitleVariant').getString());
    ssModelHierComp.updateTitleView();
end

function updateRowStyling(dlg,configDlgSchema)

    priorActivatedConfigName=configDlgSchema.updateActivatedConfigName();


    newRow=configDlgSchema.ConfigSSSrc.getChildByName(configDlgSchema.SelectedConfig);
    priorRow=configDlgSchema.ConfigSSSrc.getChildByName(priorActivatedConfigName);

    configDlgSchema.updateSpreadsheetRow(dlg,priorRow,'configsSSWidgetTag');
    configDlgSchema.updateSpreadsheetRow(dlg,newRow,'configsSSWidgetTag');

    newGlobalRow=configDlgSchema.GlobalConfigSSSrc.getChildByName(configDlgSchema.SelectedConfig);
    priorGlobalRow=configDlgSchema.GlobalConfigSSSrc.getChildByName(priorActivatedConfigName);
    configDlgSchema.updateSpreadsheetRow(dlg,priorGlobalRow,'globalWSSSWidgetTag');
    configDlgSchema.updateSpreadsheetRow(dlg,newGlobalRow,'globalWSSSWidgetTag');

end


