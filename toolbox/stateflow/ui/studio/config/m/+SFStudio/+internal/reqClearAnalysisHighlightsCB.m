function reqClearAnalysisHighlightsCB(cbinfo)




    chartId=SFStudio.Utils.getChartId(cbinfo);
    Stateflow.ReqTable.internal.DiagnosticHandler.clearDiagnosticsByType(chartId,...
    Stateflow.ReqTable.internal.DiagnosticType.AnalysisIssue);
    Stateflow.ReqTable.internal.TableManager.clearIncompletenessIcon(chartId);
end
