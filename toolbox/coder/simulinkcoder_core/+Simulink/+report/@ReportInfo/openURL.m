function openURL(url,varargin)
    if nargin>1
        title=varargin{1};
    else
        title=DAStudio.message('RTW:report:DocumentTitle','');
    end
    if nargin>2
        helpMethod=varargin{2};
    else
        helpMethod='';
    end
    if nargin>3
        bOpenInExternalBrowser=varargin{3};
    else
        bOpenInExternalBrowser=false;
    end
    if bOpenInExternalBrowser
        Simulink.report.ReportInfo.openInExternalBrowser(url);
    else
        Simulink.report.ReportInfo.openInWebkit(url,title,helpMethod);
    end
end
