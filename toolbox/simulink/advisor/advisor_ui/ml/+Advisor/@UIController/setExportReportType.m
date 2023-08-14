function result=setExportReportType(this,type)
    result=true;
    if~any(strcmp(type,{'html','pdf','docx'}))
        result=false;
        return;
    end
    this.exportReportType=type;
end