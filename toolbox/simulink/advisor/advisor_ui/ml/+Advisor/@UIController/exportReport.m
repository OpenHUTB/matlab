function result=exportReport(this,reptype)

    result=true;

    this.setExportReportType(reptype);

    [fName,fPath]=uiputfile(['*.',this.exportReportType],'Save Report',['Report_',datestr(now,'yyyy_mm_dd_HH_MM'),'.',this.exportReportType]);
    this.maObj.AdvisorWindow.bringToFront();

    if~(isequal(fName,0)||isequal(fPath,0))
        dlgObj=ModelAdvisor.ExportPDFDialog.getInstance;

        dlgObj.TaskNode=this.maObj.TaskAdvisorRoot;

        dlgObj.ReportFormat=this.exportReportType;

        dlgObj.TemplateName=this.exportReportTemplate;

        dlgObj.ReportPath=fPath;

        fName=strsplit(fName,'.');

        dlgObj.ReportName=fName{1};

        dlgObj.ViewReport=true;

        dlgObj.syncInternalValues('write');

        dlgObj.Generate;

    end

end