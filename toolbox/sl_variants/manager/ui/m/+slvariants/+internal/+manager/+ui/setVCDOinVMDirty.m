function setVCDOinVMDirty(bdHandle)




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

    if configSchema.IsStandalone||configSchema.IsSourceObjDirtyFlag


        return;
    end

    configSchema.IsSourceObjDirtyFlag=true;

    bdHandle=get_param(configSchema.BDName,'Handle');

    slvariants.internal.manager.core.setTitleDirty(bdHandle,true);
end
