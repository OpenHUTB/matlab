function analyzeReqTableRF(cbInfo,action)




    chartId=SFStudio.Utils.getChartId(cbInfo);
    action.enabled=true;
    if sf('get',chartId,'.reqTable.includeEntireModelForAnalysis')
        action.icon='analyzeReqTableInContext';
        action.description=message('stateflow_ui:studio:resources:reqAnalyzeTableInContextDescription').getString();
    else
        action.icon='updateTable';
        action.description=message('stateflow_ui:studio:resources:reqUpdateTableDescriptionListItemActionText').getString();
    end
end
