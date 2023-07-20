function switchReductionModeUtil(modelH,vmStudioHandle,reductionMode)






    import slvariants.internal.manager.ui.config.ReduceAnalyzeModes;

    modelName=getfullname(modelH);
    dlg=slvariants.internal.manager.ui.config.getConfigurationsDialog(modelName);
    configDlgSchema=dlg.getSource;

    configsDDGComp=vmStudioHandle.getComponent('GLUE2:DDG Component',message('Simulink:VariantManagerUI:ConfigsTitle').getString());


    prevModeFlag=configDlgSchema.ReduceAnalyzeModeFlag;

    switch reductionMode
    case 'Simulink:VariantManagerUI:VariantReducerCurractRadiobuttonText'
        configDlgSchema.ReduceAnalyzeModeFlag=ReduceAnalyzeModes.CurrentActCtrlVal;


        readOnlyStr=message('Simulink:VariantManagerUI:CommonReadOnly').getString();
        configsDDGComp.Title=[getModelSource(modelH),'(',readOnlyStr,')'];

        isGlobal=true;



        try

            slvariants.internal.manager.ui.importVariantControlVars(dlg,configDlgSchema,isGlobal);
        catch excep
            slvariants.internal.manager.core.restoreDiagnosticViewer(modelH);
            configDlgSchema.ReduceAnalyzeModeFlag=prevModeFlag;
            sldiagviewer.reportError(excep);
            me=MException(message('Simulink:VariantManagerUI:DummyEmptyError'));
            throw(me);
        end

        dlg.refresh();
        slvariants.internal.manager.core.hideVariableGroups(modelH);

    case 'Simulink:VariantManagerUI:VariantReducerConfigRadiobuttonText'
        configsDDGComp.Title=slvariants.internal.manager.ui.config.VMgrConstants.Configurations;
        configDlgSchema.ReduceAnalyzeModeFlag=ReduceAnalyzeModes.SpecifyVariantConfig;
        dlg.refresh();
        slvariants.internal.manager.core.hideVariableGroups(modelH);
        slvariants.internal.manager.ui.config.showCheckBoxesInConfigNamesSS(modelH);


        configsSSComp=dlg.getWidgetInterface('configsSSWidgetTag');
        if~isempty(configDlgSchema.ConfigSSSrc.Children)
            configsSSComp.select(configDlgSchema.ConfigSSSrc.Children(1));
        end

    case 'Simulink:VariantManagerUI:VariantReducerCtrlvarRadiobuttonText'
        configsDDGComp.Title=slvariants.internal.manager.ui.config.VMgrConstants.Configurations;
        configDlgSchema.ReduceAnalyzeModeFlag=ReduceAnalyzeModes.SpecifyVariableGrps;
        dlg.refresh();
        slvariants.internal.manager.ui.config.hideCheckBoxesInConfigNamesSS(modelH);


        try

            slvariants.internal.manager.core.showVariableGroups(modelH);
        catch excep
            slvariants.internal.manager.core.restoreDiagnosticViewer(modelH);
            configDlgSchema.ReduceAnalyzeModeFlag=prevModeFlag;
            sldiagviewer.reportError(excep);
            me=MException(message('Simulink:VariantManagerUI:DummyEmptyError'));
            throw(me);
        end
        varGrpsDlg=slvariants.internal.manager.ui.vargrps.getVariableGroupDialog(modelName);
        ssComp=varGrpsDlg.getWidgetInterface('varGrpSS');
        ssComp.addColumn(slvariants.internal.manager.ui.config.VMgrConstants.ReferenceValue,slvariants.internal.manager.ui.config.VMgrConstants.Values,'after');
    end
end

function source=getModelSource(modelH)

    if strcmp(get_param(modelH,'HasAccessToBaseWorkspace'),'on')
        source=slvariants.internal.manager.ui.config.VMgrConstants.BaseWorkspaceSource;
    else
        source=get_param(modelH,'DataDictionary');
    end
end


