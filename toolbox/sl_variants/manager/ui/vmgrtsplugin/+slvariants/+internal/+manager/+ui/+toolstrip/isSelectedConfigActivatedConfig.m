function enable=isSelectedConfigActivatedConfig(modelHandle)






    modelName=getfullname(modelHandle);
    dlg=slvariants.internal.manager.ui.config.getConfigurationsDialog(modelName);
    configDlgSchema=dlg.getSource;
    enable=configDlgSchema.IsSelectedConfigActivatedConfig;
end


