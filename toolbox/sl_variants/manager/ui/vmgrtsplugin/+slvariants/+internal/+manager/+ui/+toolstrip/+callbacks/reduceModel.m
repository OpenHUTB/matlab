function reduceModel(cbinfo)






    modelH=cbinfo.Context.Object.getModelHandle();
    modelName=getfullname(modelH);

    slvariants.internal.manager.core.restoreDiagnosticViewer(modelH);

    diagInterceptor=slvariants.internal.manager.ui.diag.VMgrDiagInterceptor(modelName);
    diagProcessor=Simulink.output.registerProcessor(diagInterceptor);%#ok<SETNU>
    diagCleanupObj=onCleanup(@()cleanupFcn());

    slvariants.internal.manager.core.disableUI(modelH);
    uiCleanupObj=onCleanup(@()uiCleanUpFcn(modelH));

    redDiagStageName=getString(message('Simulink:VariantManagerUI:ReducingModelDiagStage'));
    redDiagStage=sldiagviewer.createStage(redDiagStageName,ModelName=diagInterceptor.DiagnosticViewerName);%#ok<NASGU>

    vRedOpts=cbinfo.Context.Object.App.ReductionOptions;
    vRedOpts.reduceModel(modelH);

    function cleanupFcn()
        clear diagInterceptor;
        clear diagProcessor;
    end

    function uiCleanUpFcn(modelH)
        slvariants.internal.manager.core.enableUI(modelH);
        slvariants.internal.manager.ui.utils.disableModelHierSSVM(modelH);
    end
end
