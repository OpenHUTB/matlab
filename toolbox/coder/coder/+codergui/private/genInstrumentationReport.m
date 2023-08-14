function mainReportFile=genInstrumentationReport(report)





    reportContext=coder.report.ReportContext(report);
    reportContext.ClientType='instrumentation';
    reportFiles=codergui.ReportServices.Generator.run(reportContext);
    mainReportFile=reportFiles.reportFile;
end