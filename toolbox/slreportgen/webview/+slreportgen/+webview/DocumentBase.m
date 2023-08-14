classdef DocumentBase<handle




    properties(Dependent)

        OutputPath;


        PackageType;


        TemplatePath;


        TitleBarText;


        CurrentHoleId;


        OpenStatus;


        Debug;


        Locale;
    end

    properties

        ForceOverwrite{mlreportgen.report.validators.mustBeLogical};
    end

    properties(Hidden,SetAccess=protected)
        ProgressMonitor;
    end

    properties(Hidden,SetAccess=private)


        WorkingDir='';
    end

    properties(Access=protected)
        CSSPaths string="support/lib/main-css.css";
        JSPaths string="support/lib/bundle.main.js"
        WebViewLibraryPath=fullfile(matlabroot,"toolbox/slreportgen/webview/resources/lib/webview");
        WebViewPackagePath="support/lib";
    end

    properties(Access=private)


        WebViewLibraryPathFilterFcn=@(x)~endsWith(x,'.map');

        m_doc=[];
        m_mainPartName='';
        m_isOpened=false;
        m_isOKtoAppend=false;
        m_addedURLs;
        m_directlyAddFile=false;

        m_filesToCopyFiles={};
        m_filesToCopyUrls={};
        m_addedJSLib=false;
    end

    methods
        function h=DocumentBase(outputFileName)

            h.m_doc=slreportgen.report.Report(outputFileName,'html');


            h.PackageType='both';
            h.ForceOverwrite=true;
            h.TemplatePath=fullfile(slreportgen.webview.TemplatesDir,'slwebview.htmtx');
            h.TitleBarText=getString(message('slreportgen_webview:exporter:WebViewTitleBarText'));


            h.ProgressMonitor=slreportgen.webview.ProgressMonitor();


            h.m_addedURLs=containers.Map();


            h.m_addedJSLib=false;
        end

        function set.OutputPath(h,outputPath)
            h.m_doc.OutputPath=outputPath;
        end

        function outputPath=get.OutputPath(h)
            outputPath=h.m_doc.OutputPath;
        end

        function set.PackageType(h,packageType)
            h.m_doc.PackageType=lower(packageType);
        end

        function packageType=get.PackageType(h)
            packageType=h.m_doc.PackageType;
        end

        function set.TemplatePath(h,templatePath)
            h.m_doc.TemplatePath=templatePath;
        end

        function templatePath=get.TemplatePath(h)
            templatePath=h.m_doc.TemplatePath;
        end

        function set.TitleBarText(h,titleBarText)
            h.m_doc.TitleBarText=titleBarText;
        end

        function titleBarText=get.TitleBarText(h)
            titleBarText=h.m_doc.TitleBarText;
        end

        function currentHoleId=get.CurrentHoleId(h)
            if isempty(h.m_doc.Document)
                currentHoleId='';
            else
                currentHoleId=h.m_doc.Document.CurrentHoleId;
            end
        end

        function openStatus=get.OpenStatus(h)
            if isempty(h.m_doc.Document)
                openStatus='unopened';
            else
                openStatus=h.m_doc.Document.OpenStatus;
            end
        end

        function set.Debug(h,tf)
            h.m_doc.Debug=tf;
        end

        function debug=get.Debug(h)
            debug=h.m_doc.Debug;
        end

        function set.Locale(h,locale)
            h.m_doc.Locale=locale;
        end

        function locale=get.Locale(h)
            locale=h.m_doc.Locale;
        end
    end

    methods(Sealed)






        function report=getReportObject(this)
            report=this.m_doc;
        end


        function domObj=append(h,varargin)

            if~isOpened(h)
                open(h);
            end
            domObj=append(h.m_doc.Document,varargin{:});
        end

        function add(h,content)
            add(h.m_doc,content);
        end


        function success=open(h,varargin)
            success=false;
            if~h.m_isOpened

                h.m_directlyAddFile=strcmp(h.PackageType,'unzipped');

                if h.m_directlyAddFile




                    validateOutputFolder(h.OutputPath);
                end


                addCSSToHeader(h);


                open(h.m_doc,varargin{:});
                h.m_isOpened=true;
                success=true;





                outputParentPath=fileparts(h.OutputPath);
                h.WorkingDir=tempname(outputParentPath);
                mkdir(h.WorkingDir);
            end
        end


        function tf=isOpened(h)
            tf=h.m_isOpened;
        end


        function nextHoleId=moveToNextHole(h)
            nextHoleId=moveToNextHole(h.m_doc);
        end


        function fill(h)
            open(h);
            rpt=h.m_doc;

            rpt.Document.ForceOverwrite=h.ForceOverwrite;


            metaClass=metaclass(h);
            methodList={metaClass.MethodList.Name};

            holeId=rpt.Document.CurrentHoleId;
            while~strcmp(holeId,'#end#')&&~isempty(holeId)
                if(~strcmp(holeId,'#start#')&&~isempty(holeId))
                    h.m_isOKtoAppend=true;
                    fillMethod=strcat('fill',holeId);
                    if any(strcmp(fillMethod,methodList))
                        h.(fillMethod)();
                        h.addJSLibs();
                    end
                    h.m_isOKtoAppend=false;
                end
                holeId=moveToNextHole(rpt.Document);
            end
            close(h);
        end


        function success=close(h)
            success=false;
            if h.m_isOpened

                nFiles=numel(h.m_filesToCopyFiles);
                for i=1:nFiles
                    file=h.m_filesToCopyFiles{i};
                    url=h.m_filesToCopyUrls{i};
                    addFile(h,file,url);
                end


                nLibs=numel(h.WebViewLibraryPath);
                for i=1:nLibs
                    libFilePath=h.WebViewLibraryPath{i};
                    libPkgPath=h.WebViewPackagePath{i};
                    filterFcn=h.WebViewLibraryPathFilterFcn;
                    addDirectory(h,libFilePath,libPkgPath,filterFcn);
                end


                close(h.m_doc);
                h.m_isOpened=false;
                success=true;


                if h.m_directlyAddFile
                    [fOutputPath,fOutputName]=fileparts(h.OutputPath);
                    try
                        movefile(...
                        fullfile(h.WorkingDir,'*'),...
                        fullfile(fOutputPath,fOutputName),'f');
                    catch

                        copyfile(...
                        fullfile(h.WorkingDir,'*'),...
                        fullfile(fOutputPath,fOutputName),'f');
                    end
                end


                if strcmp(h.PackageType,"unzipped")
                    unzippedFolder=h.OutputPath;
                elseif strcmp(h.PackageType,"both")
                    [fOutFolder,fOutName]=fileparts(h.OutputPath);
                    unzippedFolder=fullfile(fOutFolder,fOutName);
                else
                    unzippedFolder=[];
                end

                if~isempty(unzippedFolder)&&isfolder(unzippedFolder)
                    delete(fullfile(unzippedFolder,'[Content_Types].xml'));
                    rmdir(fullfile(unzippedFolder,'_rels'),'s');
                end

                rmdir(h.WorkingDir,'s');
                h.WorkingDir='';
            end
        end


        function addFile(h,fileName,url,varargin)
            if(h.m_isOpened)
                if~isKey(h.m_addedURLs,url)
                    h.m_addedURLs(url)=true;
                    if h.m_directlyAddFile
                        copyFileToWorkingFolder(h,fileName,url);
                    else
                        addFileToPackage(h,fileName,url,varargin{:});
                    end
                end
            else
                error(message('slreportgen_webview:document:OpenedToAdd'));
            end
        end
    end

    methods(Access=private)
        function addJSLibs(h)
            if~h.m_addedJSLib
                for jsPath=h.JSPaths
                    scriptElem=mlreportgen.dom.CustomElement('script');
                    scriptElem.CustomAttributes=mlreportgen.dom.CustomAttribute('src',jsPath);
                    append(scriptElem,mlreportgen.dom.CustomText());
                    h.m_doc.append(scriptElem);
                end
                h.m_addedJSLib=true;
            end
        end

        function addCSSToHeader(h)
            for cssPath=h.CSSPaths
                h.m_doc.HTMLHeadExt=sprintf(['%s',...
                '<link href="%s" media="screen" rel="stylesheet" type="text/css"></link>\n'],...
                h.m_doc.HTMLHeadExt,...
                cssPath);
            end
        end


        function addDirectory(h,dirName,url,varargin)
            filterFcn=[];
            if~isempty(varargin)
                filterFcn=varargin{1};
            end

            listings=dir(dirName);
            for i=3:length(listings)
                listingName=listings(i).name;
                if(listings(i).isdir)
                    subDir=fullfile(dirName,listingName);
                    subUrl=strcat(url,'/',listingName);
                    addDirectory(h,subDir,subUrl,filterFcn);
                else
                    fileName=fullfile(dirName,listingName);
                    if(isempty(filterFcn)||filterFcn(fileName))
                        fileUrl=strcat(url,'/',listingName);
                        addFile(h,fileName,fileUrl);
                    end
                end
            end
        end

        function copyFileToWorkingFolder(h,fileName,url)
            [urlFilePath,urlFileName,urlFileExt]=fileparts(url);
            dstDir=fullfile(h.WorkingDir,urlFilePath);
            dstFileName=fullfile(dstDir,strcat(urlFileName,urlFileExt));

            if~strcmp(fileName,dstFileName)
                if~exist(dstDir,'dir')
                    mkdir(dstDir);
                end
                copyfile(fileName,dstFileName,'f');
                fileattrib(dstFileName,'+w');
            end
        end

        function addFileToPackage(h,fileName,url,contentType,relationshipType)
            if(nargin<4)
                contentType='';
            end

            if(nargin<5)
                relationshipType='';
            end

            [~,urlFileName,urlFileExt]=fileparts(url);
            if isempty(contentType)
                switch lower(urlFileExt)
                case{'.htm','.html','.xml'}
                    contentType='text/plain';
                case{'.xlsx','.xls'}
                    contentType='application/excel';
                case{'.pptx','.ppt'}
                    contentType='application/powerpoint';
                case{'.docx','.doc'}
                    contentType='application/word';
                case ''
                    if strcmpi(urlFileName,'LICENSE')
                        contentType='text/plain';
                    end
                otherwise
                    contentType='unknown/ext';
                end
            end
            if isempty(relationshipType)
                switch lower(urlFileExt)
                case{'.htm','.html'}
                    relationshipType='http://schemas.mathworks.com/mlreportgen.dom/2013/relationships/htmx/html';
                case{'.xlsx','.xls'}
                    relationshipType='http://schemas.mathworks.com/mlreportgen.dom/2013/relationships/htmx/xlsx';
                case{'.pptx','.ppt'}
                    relationshipType='http://schemas.mathworks.com/mlreportgen.dom/2013/relationships/htmx/pptx';
                case{'.docx','.doc'}
                    relationshipType='http://schemas.mathworks.com/mlreportgen.dom/2013/relationships/htmx/docx';
                case '.xml'
                    relationshipType='http://schemas.mathworks.com/mlreportgen.dom/2013/relationships/htmx/xml';
                case ''
                    if strcmpi(urlFileName,'LICENSE')
                        relationshipType='http://schemas.mathworks.com/slreportgen.webview/2013/relationships/license';
                    end
                otherwise
                    relationshipType='http://schemas.mathworks.com/mlreportgen.dom/2013/relationships/htmx/unknown';
                end
            end

            partName=regexprep(strcat('/',url),'//','/');



            partName=strrep(partName,' ','__');

            if isempty(h.m_mainPartName)
                [~,mainPartName,mainPartExt]=fileparts(getMainPartPath(h.m_doc.Document));
                h.m_mainPartName=strcat(mainPartName,mainPartExt);
            end

            part=mlreportgen.dom.OPCPart(partName,fileName);
            part.RelatedPart=strcat('/',h.m_mainPartName);
            part.ContentType=contentType;
            part.RelationshipType=relationshipType;

            package(h.m_doc.Document,part);
        end
    end
end

function validateOutputFolder(outputFolder)
    if isfolder(outputFolder)

        if endsWith(outputFolder,filesep)
            len=strlength(outputFolder);
            outputFolder=eraseBetween(outputFolder,len,len);
        end


        pathCell=regexp(path,pathsep,'split');
        if ispc
            isFolderOnMATLABPath=any(strcmpi(outputFolder,pathCell));
        else
            isFolderOnMATLABPath=any(strcmp(outputFolder,pathCell));
        end

        if isFolderOnMATLABPath
            error(message('slreportgen_webview:document:OutputFolderOnMATLABPath',outputFolder));
        end
    end
end