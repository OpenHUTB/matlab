function loadConfigsObjFromFile(cbinfo)




    modelHandle=cbinfo.Context.Object.getModelHandle();
    modelName=getfullname(modelHandle);

    slvariants.internal.manager.core.restoreDiagnosticViewer(modelHandle);

    diagInterceptor=slvariants.internal.manager.ui.diag.VMgrDiagInterceptor(modelName);
    diagProcessor=Simulink.output.registerProcessor(diagInterceptor);
    diagCleanupObj=onCleanup(@()cleanupFcn());

    migDiagStageName=getString(message('Simulink:VariantManagerUI:VarConfigObjStage'));
    migDiagStage=sldiagviewer.createStage(migDiagStageName,ModelName=diagInterceptor.DiagnosticViewerName);

    try





        slvariants.internal.manager.ui.config.importFromFile(modelName,diagInterceptor,diagProcessor,migDiagStage);
    catch ex
        sldiagviewer.reportError(ex);
    end
    function cleanupFcn()
        clear diagInterceptor;
        clear diagProcessor;
    end

end
