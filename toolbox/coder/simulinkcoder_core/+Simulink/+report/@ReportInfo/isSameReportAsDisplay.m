function out=isSameReportAsDisplay(obj)


    dlg=Simulink.report.ReportInfo.getBrowserDialog();


    if~rtw.report.ReportInfo.featureReportV2||~isa(obj,'rtw.report.ReportInfo')
        out=~isempty(dlg)&&isprop(dlg.getSource,'documentName')&&strcmp(dlg.getSource.documentName,obj.getReportFileFullName);
    else
        out=compareSourceV2(obj,dlg);
    end
end

function res=compareSourceV2(obj,dlg)

    if isempty(dlg)
        res=false;
        return;
    end

    dlgSrc=dlg.getSource;
    if isa(dlgSrc,'Simulink.document')
        res=false;
        return;
    end

    urlSegment=split(dlgSrc.Url,'?');
    url=urlSegment{1};

    urlPieces=split(url,'/');
    urlRel=strjoin(urlPieces(end-2:end),'/');
    reportPieces=split(obj.getReportFileFullName,filesep);
    reportRel=strjoin(reportPieces(end-2:end),'/');


    res=strcmp(urlRel,reportRel);
end
