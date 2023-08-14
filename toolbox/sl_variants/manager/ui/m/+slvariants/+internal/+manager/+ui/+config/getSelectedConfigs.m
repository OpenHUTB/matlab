function selectedConfigCell=getSelectedConfigs(modelHandle)






    selectedConfigCell={};%#ok<NASGU>

    modelName=getfullname(modelHandle);
    dlg=slvariants.internal.manager.ui.config.getConfigurationsDialog(modelName);
    configDlgSchema=dlg.getSource;

    configsSSSrc=configDlgSchema.ConfigSSSrc;
    configRows=configsSSSrc.Children;

    configNames={configRows.VarConfigName};
    selectedConfigCell=configNames([configRows.IsSelected]);

end


