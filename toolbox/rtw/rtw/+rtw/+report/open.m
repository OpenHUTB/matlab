function open(sys,varargin)



    if nargin>0
        sys=convertStringsToChars(sys);
    end
    reportInfo=rtw.report.getReportInfo(sys,varargin{:});

    if Simulink.report.ReportInfo.featureReportV2&&isfile(fullfile(reportInfo.getReportDir,'index.html'))
        mainFile=fullfile(reportInfo.getReportDir,'index.html');
    else
        mainFile=reportInfo.getContentsFileFullName;
    end

    if~isfile(mainFile)



        rtw.report.generate(sys);
        reportInfo.show;
    else

        reportInfo.show;
    end
