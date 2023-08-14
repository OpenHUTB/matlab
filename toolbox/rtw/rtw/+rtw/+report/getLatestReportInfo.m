function[rptInfo,srcSysName]=getLatestReportInfo(model)










    rptInst=rtw.report.ReportInfo.instance(model);


    if~isempty(rptInst)&&~isempty(rptInst.SourceSubsystem)
        srcSysName=rptInst.SourceSubsystem;
    else
        srcSysName=model;
    end


    rptInfo=rtw.report.getReportInfo(srcSysName);

end
