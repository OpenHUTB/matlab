function varargout=html_info_mgr(method,varargin)



























    persistent fileChildPagesMap;

    if isempty(fileChildPagesMap)
        fileChildPagesMap=containers.Map();
    end

    if isempty(method)||~ischar(method)
        error(message('Slvnv:simcoverage:html_info_mgr:NontextualMethod'));
    end

    switch(method)
    case 'load'
        if~isempty(varargin{1})
            fileLoc=varargin{1};


            fileLoc=cvi.ReportUtils.file_url_2_path(fileLoc);
        end
        newKey=createKey(fileLoc);

        fileChildPagesMap(newKey)=varargin{2};

    case 'get'
        [fileChildPagesMap,newKey]=refresh_if_needed(fileChildPagesMap);
        infoStruct=fileChildPagesMap(newKey);


        tableIdx=varargin{2};
        cellVar=getfield(infoStruct,varargin{1});%#ok<GFLD>
        varargout{1}=cellVar(tableIdx,:);
        [file,datenum1,datenum2]=fileparts(varargout{1}{1});
        varargout{1}{1}='';

        if exist(file,'file')
            fDetails=dir(file);

            if isequal(mat2str(fDetails.datenum),[datenum1,datenum2])
                varargout{1}{1}=file;
            end
        end

    case 'childpage'
        fileLoc=varargin{2};
        parentFileLoc=findCurrentPageInWeb;
        parentKey=createKey(parentFileLoc);
        parentVal=fileChildPagesMap(parentKey);
        parentVal.lookupTableInfo{varargin{1},1}=createKey(fileLoc);
        fileChildPagesMap(parentKey)=parentVal;

    otherwise
        error(message('Slvnv:simcoverage:html_info_mgr:UnknownMethod'));
    end



    function[fileChildPagesMap,thisKey]=refresh_if_needed(fileChildPagesMap)

        currFileLoc=findCurrentPageInWeb;
        thisKey=createKey(currFileLoc);
        reloadData=~fileChildPagesMap.isKey(thisKey);



        if numel(currFileLoc)>=10&&strcmp(currFileLoc((end-9):end),'_main.html')
            currFileLoc=find_base_contents_name(currFileLoc);
        end

        if reloadData
            fileChildPagesMap(thisKey)=get_html_data(currFileLoc);
        end


        function data=get_html_data(fileName)

            fileName=cvi.ReportUtils.file_url_2_path(fileName);
            data=get_persistent_data_from_html(fileName);


            function mainTarget=find_base_contents_name(topFileLoc)


                mainTarget='';


                topFileLoc=cvi.ReportUtils.file_url_2_path(topFileLoc);

                fid=fopen(topFileLoc,'r');

                strLine=fgetl(fid);
                while ischar(strLine)
                    if(~isempty(strLine)&&contains(strLine,'<frame name="mainFrame" src="'))
                        startIdx=strfind(strLine,'src="')+5;
                        mainTarget=strtok(strLine(startIdx:end),'"');
                        mainTarget=strrep(mainTarget,'file:///','');
                        break;
                    end
                    strLine=fgetl(fid);
                end

                if isempty(mainTarget)
                    mainTarget=topFileLoc;
                end

                function data=get_persistent_data_from_html(fileName)
                    expr1=regexptranslate('escape','<MX2STR STRING="');
                    expr2=regexptranslate('escape','"/>');
                    safeExpr=[expr1,'(.*?)',expr2];

                    fid=fopen(fileName,'r','n','utf-8');
                    gaurd=onCleanup(@()fclose(fid));
                    fileContents=fread(fid,'*char')';

                    matches=regexp(fileContents,safeExpr,'tokens');
                    thisMatch=strrep(matches{:}{:},'\n',newline);
                    thisMatch=strrep(thisMatch,'\l','<');
                    thisMatch=strrep(thisMatch,'\g','>');
                    thisMatch=strrep(thisMatch,'\q','"');
                    thisMatch=strrep(thisMatch,'\\','\');
                    data=sf('Private','str2mx',thisMatch);

                    function currFileLoc=findCurrentPageInWeb
                        warningState=warning('off','MATLAB:web:BrowserAndUrlOuptputArgsRemovedInFutureRelease');
                        warningCleanup=onCleanup(@()warning(warningState));

                        [status,~,currentpage]=web;%#ok<WEBREMOVE> 
                        if status
                            return;
                        end

                        currFileLoc=cvi.ReportUtils.file_url_2_path(currentpage);


                        currFileLoc=strrep(currFileLoc,'/',filesep);
                        currFileLoc=strrep(currFileLoc,'\',filesep);

                        function key=createKey(filepath)
                            key=[filepath,filesep,mat2str(getfield(dir(filepath),'datenum'))];


