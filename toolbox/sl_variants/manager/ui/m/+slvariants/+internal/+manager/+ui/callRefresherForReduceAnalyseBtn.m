function callRefresherForReduceAnalyseBtn(modelName)






    modelHandle=get_param(modelName,'handle');
    vmStudioHandle=slvariants.internal.manager.core.getStudio(modelHandle);
    toolStrip=vmStudioHandle.getToolStrip;
    as=toolStrip.getActionService();

    currentTab=toolStrip.ActiveTab;
    if strcmp(currentTab,'variantReducerTab')
        as.refreshAction('reduceModelPushButtonAction');
    elseif strcmp(currentTab,'variantAnalyzerTab')

        as.refreshAction('analyzeModelPushButtonAction');
    end
end
