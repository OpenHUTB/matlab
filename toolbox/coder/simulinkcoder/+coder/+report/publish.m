function publish(sys,varargin)















    if nargin>0
        sys=convertStringsToChars(sys);
    end

    model=bdroot(sys);

    aStdRpt=[];
    for i=1:nargin-1
        if isa(varargin{i},'StdRpt.RTW')
            aStdRpt=varargin{i};
        end
    end
    if strcmp(get_param(model,'IsERTTarget'),'on')
        if~builtin('license','checkout','RTW_Embedded_Coder')
            DAStudio.error('RTW:report:ECoderStdRptLicense')
        end
    else
        if~builtin('license','checkout','Real-Time_Workshop')
            DAStudio.error('RTW:report:CoderStdRptLicense');
        end
    end
    if~builtin('license','checkout','MATLAB_Report_Gen')||...
        ~builtin('license','checkout','SIMULINK_Report_Gen')
        DAStudio.error('RTW:report:StdRptRptGenLicense');
    end


    if isempty(aStdRpt)
        aStdRptDlg=StdRptDlg.RTW(model);
        if isa(aStdRptDlg,'StdRptDlg.RTW')
            aStdRpt=aStdRptDlg.getCfg;
        end
    end

    aStdRpt.rootSystem=sys;
    reportInfo=rtw.report.getReportInfo(sys);
    if isa(reportInfo,'rtw.report.ReportInfo')
        reportInfo.link(model);
        coder.report.internal.slcoderPublishCode.publish(aStdRpt,reportInfo);
    end


