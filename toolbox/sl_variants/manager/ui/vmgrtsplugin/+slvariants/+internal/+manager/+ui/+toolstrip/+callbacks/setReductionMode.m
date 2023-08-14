function setReductionMode(cbInfo)









    eventData=cbInfo.EventData;
    ctxApp=cbInfo.Context.Object.App;
    ctxApp.ReductionOptions.ReductionMode=eventData;

    modelH=ctxApp.ModelHandle;

    vmStudioHandle=slvariants.internal.manager.core.getStudio(modelH);


    modelName=getfullname(modelH);
    diagInterceptor=slvariants.internal.manager.ui.diag.VMgrDiagInterceptor(modelName);
    diagProcessor=Simulink.output.registerProcessor(diagInterceptor);%#ok<SETNU>
    diagCleanupObj=onCleanup(@()cleanupFcn());

    redModeDiagStageName=getString(message('Simulink:VariantManagerUI:ReductionModeDiagStage'));
    redDiagStage=sldiagviewer.createStage(redModeDiagStageName,ModelName=diagInterceptor.DiagnosticViewerName);%#ok<NASGU>
    slvariants.internal.manager.ui.utils.switchReductionModeUtil(modelH,vmStudioHandle,eventData);


    toolStrip=vmStudioHandle.getToolStrip;
    as=toolStrip.getActionService();
    as.refreshAction('reduceModelPushButtonAction');

    function cleanupFcn()
        clear diagInterceptor;
        clear diagProcessor;
    end
end


