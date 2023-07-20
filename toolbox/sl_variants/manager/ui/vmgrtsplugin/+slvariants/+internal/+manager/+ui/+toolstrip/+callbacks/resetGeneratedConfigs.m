function resetGeneratedConfigs(cbinfo)







    modelH=cbinfo.Context.Object.getModelHandle();
    modelName=getfullname(modelH);

    slvariants.internal.manager.core.restoreDiagnosticViewer(modelH);

    diagInterceptor=slvariants.internal.manager.ui.diag.VMgrDiagInterceptor(modelName);
    diagProcessor=Simulink.output.registerProcessor(diagInterceptor);%#ok<SETNU> 
    diagCleanupObj=onCleanup(@()cleanupFcn());

    slvariants.internal.manager.core.disableUI(modelH);
    cleanupObj=onCleanup(@()slvariants.internal.manager.core.enableUI(modelH));

    migDiagStageName=getString(message('Simulink:VariantManagerUI:ResetGeneratedConfigsDiagStage'));
    migDiagStage=sldiagviewer.createStage(migDiagStageName,ModelName=diagInterceptor.DiagnosticViewerName);%#ok<NASGU>

    autoGenBroker=cbinfo.Context.Object.App.AutoGenConfigToolStripBroker;
    autoGenBroker.reset(modelH);

    function cleanupFcn()
        clear diagInterceptor;
        clear diagProcessor;
    end
end
