function tf=isReqTable(cbinfo)
    sfObj=cbinfo.uiObject;
    chartId=sfprivate('getChartOf',sfObj.Id);
    tf=Stateflow.ReqTable.internal.isRequirementsTable(chartId);

end
