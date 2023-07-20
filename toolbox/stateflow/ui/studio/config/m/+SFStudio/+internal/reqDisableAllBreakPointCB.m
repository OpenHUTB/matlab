function reqDisableAllBreakPointCB(cbinfo)






    chartId=SFStudio.Utils.getChartId(cbinfo);
    isReq=Stateflow.ReqTable.internal.isRequirementsTable(chartId);
    if isReq
        return;
    end
end
