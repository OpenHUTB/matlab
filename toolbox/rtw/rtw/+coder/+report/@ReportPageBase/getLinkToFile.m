function out=getLinkToFile(obj,fullFileName)
    rptFullFileName=fullfile(obj.ReportFolder,obj.getReportFileName());
    tmp=obj.getLinkManager();
    out=tmp.getLinkToFile(rptFullFileName,fullFileName);
end
