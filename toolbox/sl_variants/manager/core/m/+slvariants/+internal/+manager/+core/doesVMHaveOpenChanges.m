function isDirty=doesVMHaveOpenChanges(modelName)





    isDirty=false;

    bdHandle=get_param(modelName,'Handle');
    if~slvariants.internal.manager.core.hasOpenVM(bdHandle)
        return;
    end
    dlg=slvariants.internal.manager.ui.config.getConfigurationsDialog(modelName);
    configSchema=dlg.getSource;
    isDirty=configSchema.IsSourceObjDirtyFlag;

end


