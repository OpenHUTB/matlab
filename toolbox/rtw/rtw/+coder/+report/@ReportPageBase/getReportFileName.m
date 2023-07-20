function out=getReportFileName(obj)
    if isempty(obj.ReportFileName)
        out=obj.getDefaultReportFileName();
    else
        out=obj.ReportFileName;
    end
end
