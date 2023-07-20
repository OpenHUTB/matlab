function analyzeModel(cbInfo)









    ctxApp=cbInfo.Context.Object.App;
    configAnalysisMode=ctxApp.ConfigAnalysisMode;
    modelH=ctxApp.ModelHandle;
    modelName=getfullname(modelH);

    slvariants.internal.manager.core.restoreDiagnosticViewer(modelH);

    diagInterceptor=slvariants.internal.manager.ui.diag.VMgrDiagInterceptor(modelName);
    diagProcessor=Simulink.output.registerProcessor(diagInterceptor);%#ok<SETNU>
    diagCleanupObj=onCleanup(@()cleanupFcn());

    slvariants.internal.manager.core.disableUI(modelH);
    cleanupObj=onCleanup(@()uiCleanUpFcn(modelH));

    migDiagStageName=getString(message('Simulink:VariantManagerUI:AnalyzeModelDiagStage'));
    migDiagStage=sldiagviewer.createStage(migDiagStageName,ModelName=diagInterceptor.DiagnosticViewerName);%#ok<NASGU>

    configPVArgs={};
    switch configAnalysisMode
    case 'Simulink:VariantManagerUI:VariantReducerConfigRadiobuttonText'

        selectedConfigs=slvariants.internal.manager.ui.config.getSelectedConfigs(modelH);
        configPVArgs={'NamedConfigurations',selectedConfigs};
    case 'Simulink:VariantManagerUI:VariantReducerCtrlvarRadiobuttonText'

        configPVArgs=slvariants.internal.manager.ui.vargrps.getVariableGroupsPVArgs(modelH);
    end

    if~isempty(ctxApp.ConfigAnalysisObj)
        ctxApp.ConfigAnalysisObj.delete();
    end
    try
        ctxApp.ConfigAnalysisObj=Simulink.VariantConfigurationAnalysis(modelName,configPVArgs{:});
        ctxApp.ConfigAnalysisObj.showUI();
    catch errorMsg
        sldiagviewer.reportError(errorMsg);
    end







    function cleanupFcn()
        clear diagInterceptor;
        clear diagProcessor;
    end

    function uiCleanUpFcn(modelH)
        slvariants.internal.manager.core.enableUI(modelH);
        slvariants.internal.manager.ui.utils.disableModelHierSSVM(modelH);
    end
end


