function setEnableReduceModelButton(cbinfo,action)



    ctxApp=cbinfo.Context.Object.App;
    modelH=ctxApp.ModelHandle;

    reductionMode=ctxApp.ReductionOptions.ReductionMode;

    btnName=getString(message('Simulink:VariantManagerUI:VariantReducerReduceButtonText'));
    [isSelected,tooltipDesc]=slvariants.internal.manager.ui.isAnyItemSelectedForReduceAnalyze(modelH,reductionMode,btnName);

    action.enabled=isSelected;
    action.description=tooltipDesc;
end
