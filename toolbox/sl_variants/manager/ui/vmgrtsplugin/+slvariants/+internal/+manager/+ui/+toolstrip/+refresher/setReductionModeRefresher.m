function setReductionModeRefresher(cbinfo,action)




    import slvariants.internal.manager.ui.config.ReduceAnalyzeModes;

    bdHandle=cbinfo.Context.Object.getModelHandle();
    modelName=getfullname(bdHandle);
    dlg=slvariants.internal.manager.ui.config.getConfigurationsDialog(modelName);
    configSchema=dlg.getSource;

    switch configSchema.ReduceAnalyzeModeFlag
    case ReduceAnalyzeModes.SpecifyVariableGrps
        action.selectedItem='Simulink:VariantManagerUI:VariantReducerCtrlvarRadiobuttonText';
    case ReduceAnalyzeModes.CurrentActCtrlVal
        action.selectedItem='Simulink:VariantManagerUI:VariantReducerCurractRadiobuttonText';
    case ReduceAnalyzeModes.SpecifyVariantConfig
        action.selectedItem='Simulink:VariantManagerUI:VariantReducerConfigRadiobuttonText';
    end
end


