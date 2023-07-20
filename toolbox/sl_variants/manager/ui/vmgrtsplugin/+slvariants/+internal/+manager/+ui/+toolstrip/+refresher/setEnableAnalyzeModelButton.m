function setEnableAnalyzeModelButton(cbinfo,action)




    ctxApp=cbinfo.Context.Object.App;
    modelH=ctxApp.ModelHandle;

    analysisMode=ctxApp.ConfigAnalysisMode;

    btnName=getString(message('Simulink:VariantManagerUI:VariantConfigurationAnalysisAnalyzeButtonText'));



    [isSelected,toolTipDesc]=slvariants.internal.manager.ui.isAnyItemSelectedForReduceAnalyze(modelH,analysisMode,btnName);

    action.enabled=isSelected;
    action.description=toolTipDesc;
end
