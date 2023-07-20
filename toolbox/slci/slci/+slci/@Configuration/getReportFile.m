function out=getReportFile(aObj)






    aObj.createReportFolder();
    out=fullfile(aObj.getReportFolder(),...
    [aObj.getModelName(),'_report.html']);




    out=slci.internal.ReportUtil.convertRelativeToAbsolute(out);
end

