function varargout=local_browser_mgr(method,varargin)






    switch(method)
    case 'displayFile'
        filePath=varargin{1};
        url=cvi.ReportUtils.file_path_2_url(filePath);

        warningState=warning('off','MATLAB:web:BrowserOuptputArgRemovedInFutureRelease');
        warningCleanup=onCleanup(@()warning(warningState));
        [~,hBrowser]=web(url);
        if nargout>0
            varargout{1}=hBrowser;
        end
    case 'rootCovFile'

        warningState=warning('off','MATLAB:web:BrowserAndUrlOuptputArgsRemovedInFutureRelease');
        warningCleanup=onCleanup(@()warning(warningState));
        [status,~,currFileLoc]=web;
        if~status
            baseFileName=cvi.ReportUtils.file_url_2_path(currFileLoc);
            if(~isempty(findstr(baseFileName,'_main.html')))%#ok<FSTR>
                baseFileName=find_base_contents_name(baseFileName);
            end
            varargout{1}=baseFileName;
        else
            varargout{1}=[];
        end

    otherwise
        assert(false,getString(message('Slvnv:simcoverage:private:UnrecognizedMethod')));
    end


    function mainTarget=find_base_contents_name(topFileLoc)


        mainTarget='';

        topFileLoc=cvi.ReportUtils.file_url_2_path(topFileLoc);

        fid=fopen(topFileLoc,'r');


        while 1
            strLine=fgetl(fid);
            if~ischar(strLine)
                break;
            end
            if findstr(strLine,'<frame name="mainFrame" src="')%#ok<FSTR>
                startIdx=findstr(strLine,'src="')+5;%#ok<FSTR>
                mainTarget=strtok(strLine(startIdx:end),'"');
                break;
            end

        end
        fclose(fid);

        if isempty(mainTarget)
            mainTarget=topFileLoc;
        end
