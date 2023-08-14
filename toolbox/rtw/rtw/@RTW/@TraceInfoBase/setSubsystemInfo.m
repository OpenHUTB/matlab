function setSubsystemInfo(h,subsystem,currModel)




    if~isempty(subsystem)
        h.SourceSystem=subsystem;

        h.TmpModel=currModel;
    else
        h.SourceSystem='';
        h.TmpModel='';
    end
    h.ReuseInfo=locGetData(h.Model);

    function out=locGetData(model)

        out=[];
        reportInfo=rtw.report.ReportInfo.instance(model);
        if isa(reportInfo,'rtw.report.ReportInfo')
            subsystemPage=reportInfo.getPage('Subsystem');
            if~isempty(subsystemPage)
                out=subsystemPage.getRawData;
            end
        end
