function out=getReportInfo(h)




    if~isempty(h.SourceSystem)
        sys=h.SourceSystem;
    else
        sys=h.Model;
    end
    out=rtw.report.getReportInfo(sys,h.BuildDir);
