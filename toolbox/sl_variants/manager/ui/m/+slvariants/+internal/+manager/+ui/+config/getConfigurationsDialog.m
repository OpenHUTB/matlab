function dlg=getConfigurationsDialog(modelName)




    modelHandle=get_param(modelName,'Handle');
    configsComp=slvariants.internal.manager.ui.config.getConfigurationsComp(modelHandle);
    dlg=configsComp.getDialog();
end


