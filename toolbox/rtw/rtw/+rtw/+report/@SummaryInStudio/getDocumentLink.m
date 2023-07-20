function out=getDocumentLink(obj)
    out=getDocumentLink@coder.report.ReportPageBase(obj);
    if Simulink.report.ReportInfo.featureOpenInStudio

        out.setAttribute('style','display: none');
    end
end
