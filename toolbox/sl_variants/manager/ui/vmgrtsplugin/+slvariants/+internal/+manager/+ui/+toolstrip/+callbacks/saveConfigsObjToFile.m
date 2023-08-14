function saveConfigsObjToFile(cbinfo)




    modelHandle=cbinfo.Context.Object.getModelHandle();
    modelName=getfullname(modelHandle);
    dlg=slvariants.internal.manager.ui.config.getConfigurationsDialog(modelName);

    slvariants.internal.manager.core.restoreDiagnosticViewer(modelHandle);

    diagInterceptor=slvariants.internal.manager.ui.diag.VMgrDiagInterceptor(modelName);
    diagProcessor=Simulink.output.registerProcessor(diagInterceptor);%#ok<SETNU>
    diagCleanupObj=onCleanup(@()cleanupFcn());

    migDiagStageName=getString(message('Simulink:VariantManagerUI:VarConfigObjStage'));
    migDiagStage=sldiagviewer.createStage(migDiagStageName,ModelName=diagInterceptor.DiagnosticViewerName);%#ok<NASGU>


    slvariants.internal.manager.core.disableUI(modelHandle);
    uiCleanupObj=onCleanup(@()uiCleanUpFcn(modelHandle));

    try
        slvariants.internal.manager.ui.config.exportToFile(dlg,dlg.getSource);
    catch ex
        sldiagviewer.reportError(ex);
    end

    function uiCleanUpFcn(modelHandle)
        if slvariants.internal.manager.core.hasOpenVM(modelHandle)
            slvariants.internal.manager.core.enableUI(modelHandle);
        end
    end

    function cleanupFcn()
        clear diagInterceptor;
        clear diagProcessor;
    end
end
