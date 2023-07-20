function[enable,toolTipDesc]=isAnyItemSelectedForReduceAnalyze(modelHandle,selectedEntry,btnName)






    enable=true;

    switch selectedEntry
    case 'Simulink:VariantManagerUI:VariantReducerCurractRadiobuttonText'
        enable=true;
        toolTipDesc=getString(message('Simulink:VariantManagerUI:ReduceModelForCurrActMode'));
    case 'Simulink:VariantManagerUI:VariantReducerConfigRadiobuttonText'

        modelName=getfullname(modelHandle);
        dlg=slvariants.internal.manager.ui.config.getConfigurationsDialog(modelName);
        configDlgSchema=dlg.getSource;

        enable=any([configDlgSchema.ConfigSSSrc.Children.IsSelected]);
        if enable
            toolTipDesc=getString(message('Simulink:VariantManagerUI:ReduceOrAnalyzeForSelectedConfigs',btnName));
        else
            toolTipDesc=getString(message('Simulink:VariantManagerUI:SelectConfigsToReduceOrAnalyze',btnName));
        end
    case 'Simulink:VariantManagerUI:VariantReducerCtrlvarRadiobuttonText'
        vmStudioHandle=slvariants.internal.manager.core.getStudio(modelHandle);

        varGrpsDDGComp=vmStudioHandle.getComponent('GLUE2:DDG Component',message('Simulink:VariantManagerUI:VariableGroupsTabTitle').getString());

        enable=any([varGrpsDDGComp.getSource().VarGrpNamesSSSrc.Children.IsSelected]);
        if enable
            toolTipDesc=getString(message('Simulink:VariantManagerUI:ReduceOrAnalyzeForSelectedGroups',btnName));
        else
            toolTipDesc=getString(message('Simulink:VariantManagerUI:SelectGroupsToReduceOrAnalyze',btnName));
        end
    end
end


