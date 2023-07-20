function generate(sys,varargin)



    if nargin>0
        sys=convertStringsToChars(sys);
    end

    reportInfo=rtw.report.getReportInfo(sys);
    reportInfo.generate(varargin{:});
    if~isempty(reportInfo.getRootSystem)
        modelName=bdroot(reportInfo.getRootSystem);
    else
        modelName=reportInfo.ModelName;
    end
    if strcmp(get_param(modelName,'LaunchReport'),'on')
        reportInfo.show;
    end
