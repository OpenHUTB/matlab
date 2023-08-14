function schema=reqShowReport(cbinfo)
    schema=sl_action_schema;
    schema.label=SLStudio.Utils.getMessage(cbinfo,'stateflow_ui:studio:resources:ShowReport');
    schema.callback=@reqShowReportCB;
    schema.icon='showReportReqTable';
    schema.state='Enabled';

    analysisEnabled=license('test','Simulink_Design_Verifier')>0;
    if~analysisEnabled
        schema.state='Disabled';
    end
end


function reqShowReportCB(cbinfo)
    chartId=SFStudio.Utils.getSubviewerId(cbinfo);
    sfreq.internal.analysis.AnalysisReportPanel.openReportForChart(chartId);
end