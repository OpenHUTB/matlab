function switchConfigAnalysisModeUtil(modelH,vmStudioHandle,analysisMode)%#ok<INUSD>






    import slvariants.internal.manager.ui.config.ReduceAnalyzeModes;

    modelName=getfullname(modelH);
    dlg=slvariants.internal.manager.ui.config.getConfigurationsDialog(modelName);
    configDlgSchema=dlg.getSource;


    prevModeFlag=configDlgSchema.ReduceAnalyzeModeFlag;

    switch analysisMode
    case 'Simulink:VariantManagerUI:VariantReducerConfigRadiobuttonText'
        configDlgSchema.ReduceAnalyzeModeFlag=ReduceAnalyzeModes.SpecifyVariantConfig;
        slvariants.internal.manager.core.hideVariableGroups(modelH);
        slvariants.internal.manager.ui.config.showCheckBoxesInConfigNamesSS(modelH);


        configsSSComp=dlg.getWidgetInterface('configsSSWidgetTag');
        if~isempty(configDlgSchema.ConfigSSSrc.Children)
            configsSSComp.select(configDlgSchema.ConfigSSSrc.Children(1));
        end

    case 'Simulink:VariantManagerUI:VariantReducerCtrlvarRadiobuttonText'
        configDlgSchema.ReduceAnalyzeModeFlag=ReduceAnalyzeModes.SpecifyVariableGrps;
        slvariants.internal.manager.ui.config.hideCheckBoxesInConfigNamesSS(modelH);


        try

            slvariants.internal.manager.core.showVariableGroups(modelH);
        catch exep
            slvariants.internal.manager.core.restoreDiagnosticViewer(modelH);
            configDlgSchema.ReduceAnalyzeModeFlag=prevModeFlag;
            sldiagviewer.reportError(exep);
            me=MException(message('Simulink:VariantManagerUI:DummyEmptyError'));
            throw(me);
        end
        varGrpsDlg=slvariants.internal.manager.ui.vargrps.getVariableGroupDialog(modelName);
        ssComp=varGrpsDlg.getWidgetInterface('varGrpSS');
        ssComp.removeColumn(slvariants.internal.manager.ui.config.VMgrConstants.ReferenceValue);
    end
end


