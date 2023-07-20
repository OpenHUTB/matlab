function displayReport(this,varargin)




    if nargin>1&&~strcmp(varargin{1},'norefresh')
        htmlfile=varargin{1};
    else
        htmlfile=this.AtticData.DiagnoseRightFrame;
    end


    if this.NOBROWSER
        return
    end

    warnID='MATLAB:web:BrowserOuptputArgRemovedInFutureRelease';
    warnPrev=warning('query',warnID);
    c=onCleanup(@()warning(warnPrev.state,warnPrev.identifier));
    warning('off',warnID);

    [~,this.BrowserWindow]=web(htmlfile);

