function mainReportFile=genSystemBlockReport(report,blockSid,folder)




    reportContext=coder.report.ReportContext(report);
    reportContext.ReportDirectory=folder;
    reportContext.SimulinkSID=blockSid;
    reportContext.ClientType='systemblock';
    reportFiles=codergui.ReportServices.Generator.run(reportContext);
    mainReportFile=reportFiles.reportFile;
end