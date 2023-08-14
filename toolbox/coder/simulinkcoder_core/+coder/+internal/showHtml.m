function varargout=showHtml(htmlFileName,varargin)













    if nargout==1&&nargin==0
        varargout{1}=IEBrowserObj;
        return
    end

    if nargin>2
        title=varargin{2}{1};
        helpMethod=varargin{2}{2};
    else
        title='';
        helpMethod='';
    end

    if nargin>1&&strcmp(varargin{1},'UseExternalWebBrowser')
        rtw.report.ReportInfo.openURL(htmlFileName,title,helpMethod,true);
    else
        rtw.report.ReportInfo.openURL(htmlFileName,title,helpMethod);
    end

