function out=getSummaryReportFile(aObj)





    aObj.createSummaryReportFolder();
    out=fullfile(aObj.getSummaryReportFolder(),...
    [aObj.getModelName(),'_summaryReport.html']);



    out=slci.internal.ReportUtil.convertRelativeToAbsolute(out);
end

