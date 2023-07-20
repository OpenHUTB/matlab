function output=DefaultReportCallback(CheckObj)
    reportObj=ModelAdvisor.Report.StyleFactory.creator(CheckObj.ReportStyle);
    output=reportObj.generateReport(CheckObj);
end
