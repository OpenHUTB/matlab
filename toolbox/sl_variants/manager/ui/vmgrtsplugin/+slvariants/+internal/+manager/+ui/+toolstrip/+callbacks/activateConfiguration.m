function activateConfiguration(cbinfo)




    modelHandle=cbinfo.Context.Object.getModelHandle();
    modelName=getfullname(modelHandle);
    dlg=slvariants.internal.manager.ui.config.getConfigurationsDialog(modelName);




    slvariants.internal.manager.ui.compbrowser.SpreadSheetTabChange.setCompBrowserVisible(modelName,false);
    dlg.refresh();

    slvariants.internal.manager.core.restoreDiagnosticViewer(modelHandle);

    diagInterceptor=slvariants.internal.manager.ui.diag.VMgrDiagInterceptor(modelName);
    diagProcessor=Simulink.output.registerProcessor(diagInterceptor);%#ok<SETNU> 
    diagCleanupObj=onCleanup(@()cleanupFcn());

    configDlgSchema=dlg.getSource;


    if strcmp(configDlgSchema.SelectedConfig,configDlgSchema.ConfigSSSrc.GlobalWksConfig.Name)



        slvariants.internal.manager.ui.exportVariantControlVars(dlg,configDlgSchema);
        configName='';
        configStageName=configDlgSchema.ConfigSSSrc.GlobalWksConfig.Name;
    else

        configName=configDlgSchema.SelectedConfig;
        configStageName=configName;
    end
    configDlgSchema.setExportBtnStateOnExportOrActivate(dlg);




    vmStudioHandle=slvariants.internal.manager.core.getStudio(modelHandle);


    toolStrip=vmStudioHandle.getToolStrip;

    as=toolStrip.getActionService();
    as.refreshAction('viewBlocksFilterAction');
    as.refreshAction('navigateChoicesComboBoxAction');
    as.refreshAction('navigateLabelAction');
    as.refreshAction('viewBlocksLabelAction');

    actDiagStageName=getString(message('Simulink:VariantManagerUI:ActivationStage',configStageName));
    actDiagStage=sldiagviewer.createStage(actDiagStageName,ModelName=diagInterceptor.DiagnosticViewerName);%#ok<NASGU>

    slvariants.internal.manager.ui.activateModelForUI(dlg,configName);




    helpCompIdx=slvariants.internal.manager.ui.utils.getHelpComponentIndices();


    slvariants.internal.manager.ui.utils.setHelpDocIndex(vmStudioHandle,helpCompIdx.ActivateConfig);

    function cleanupFcn()
        clear diagInterceptor;
        clear diagProcessor;
    end
end


