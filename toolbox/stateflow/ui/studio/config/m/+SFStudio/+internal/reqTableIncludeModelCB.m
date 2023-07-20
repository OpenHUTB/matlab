function reqTableIncludeModelCB(cbInfo,~)




    chartId=SFStudio.Utils.getChartId(cbInfo);
    flag=sf('get',chartId,'.reqTable.includeEntireModelForAnalysis');
    sf('set',chartId,'.reqTable.includeEntireModelForAnalysis',~flag);

    dig.postStringEvent('SimulinkEvent:Simulation');
end
