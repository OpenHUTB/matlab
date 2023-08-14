function out=getReportFileName(obj)
    if isempty(obj.ReportFileName)
        out=[obj.ModelName,'_',obj.getDefaultReportFileName()];
    else
        out=obj.ReportFileName;
    end
end
