function tf=isStateflowApp(cbinfo)
    chartId=SFStudio.Utils.getChartId(cbinfo);
    tf=chartId&&Stateflow.App.IsStateflowApp(chartId);
end