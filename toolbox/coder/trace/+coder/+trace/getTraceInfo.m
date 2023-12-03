function traceInfo=getTraceInfo(sys,varargin)

    traceInfo=[];
    try
        rptInfo=rtw.report.getReportInfo(sys,varargin{:});
    catch
        rptInfo=[];
    end

    if~isempty(rptInfo)
        traceInfo=coder.trace.getTraceInfoByReportInfo(rptInfo);
    end

end

