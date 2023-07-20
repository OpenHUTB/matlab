function setConfigAnalysisMode(cbInfo)









    eventData=cbInfo.EventData;
    ctxApp=cbInfo.Context.Object.App;
    ctxApp.ConfigAnalysisMode=eventData;

    modelH=ctxApp.ModelHandle;
    vmStudioHandle=slvariants.internal.manager.core.getStudio(modelH);


    modelName=getfullname(modelH);
    diagInterceptor=slvariants.internal.manager.ui.diag.VMgrDiagInterceptor(modelName);
    diagProcessor=Simulink.output.registerProcessor(diagInterceptor);%#ok<SETNU>
    diagCleanupObj=onCleanup(@()cleanupFcn());

    analysisModeStageName=getString(message('Simulink:VariantManagerUI:AnalysisModeDiagStage'));
    analysisDiagStage=sldiagviewer.createStage(analysisModeStageName,ModelName=diagInterceptor.DiagnosticViewerName);%#ok<NASGU>

    slvariants.internal.manager.ui.utils.switchConfigAnalysisModeUtil(modelH,vmStudioHandle,eventData);


    toolStrip=vmStudioHandle.getToolStrip;
    as=toolStrip.getActionService();
    as.refreshAction('analyzeModelPushButtonAction');

    function cleanupFcn()
        clear diagInterceptor;
        clear diagProcessor;
    end
end


