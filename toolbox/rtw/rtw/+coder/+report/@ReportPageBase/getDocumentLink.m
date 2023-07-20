function out=getDocumentLink(rpt)
    out=Advisor.Element;
    out.setTag('a');
    if~isempty(rpt.ReportFileName)
        out.setAttribute('href',rpt.ReportFileName);
    else
        out.setAttribute('href',rpt.getDefaultReportFileName);
    end
    out.setAttribute('id',rpt.getId);
    out.setContent(rpt.getShortTitle);
end
