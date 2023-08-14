function activateButtonToolTip(cbinfo,action)






    modelHandle=cbinfo.Context.Object.getModelHandle();
    modelName=getfullname(modelHandle);
    dlg=slvariants.internal.manager.ui.config.getConfigurationsDialog(modelName);
    configDlgSchema=dlg.getSource;
    action.description=getString(message('Simulink:VariantManagerUI:HierarchyButtonActivateTooltip',...
    configDlgSchema.SelectedConfig));

    if~cbinfo.Context.Object.getIsVMOpen()
        cbinfo.Context.Object.setIsVMOpen(true);
        slvariants.internal.manager.ui.utils.expandModelHierarchyRootRow(modelHandle);
    end
end


