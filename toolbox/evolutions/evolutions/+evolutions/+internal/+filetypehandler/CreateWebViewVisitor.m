classdef CreateWebViewVisitor<evolutions.internal.filetypehandler.Visitor




    properties
WebViewEnable
    end

    properties(SetAccess=immutable)
GeneratedFolderName
GeneratedFolderPath
    end

    properties(SetAccess=protected,GetAccess=public)
HtmlPath
    end

    properties(Constant,Access=protected)
        PreviewFilePath=fullfile(matlabroot,'toolbox','evolutions',...
        'evolutions','+evolutions','+internal','resources','layout',...
        'NoPreview.html');
    end

    methods
        function obj=CreateWebViewVisitor(folderPath)
            obj.GeneratedFolderName='webview';
            obj.GeneratedFolderPath=folderPath;
            obj.HtmlPath=char.empty;
        end
    end

    methods(Access=protected)
        function visitMFile(obj,fileType)
            try
                createScriptView(obj,fileType);
            catch ME
                obj.nonCriticalError(ME,fileType);
            end
        end

        function visitMlxFile(obj,fileType)
            viewPath=createViewFolder(obj);
            [~,name,~]=fileparts(fileType.FilePath);
            htmlFileName=fullfile(viewPath,strcat(name,'.html'));
            obj.HtmlPath=export(fileType.FilePath,htmlFileName);
        end

        function visitModelFile(obj,fileType)

            try
                if obj.WebViewEnable
                    generateWebView(obj,fileType);
                else
                    generateDiagramView(obj,fileType);
                end
            catch ME
                obj.nonCriticalError(ME,fileType);
            end
        end

        function visitDDFile(obj,fileType)
            try
                ddreport=slreportgen.report.DataDictionary(fileType.FilePath);
                [~,name]=fileparts(fileType.FilePath);
                createReport(obj,ddreport,name);
            catch ME
                obj.nonCriticalError(ME,fileType);
            end
        end

        function visitMatFile(obj,fileType)

            try
                matVar=load(fileType.FilePath);
                [~,fileName]=fileparts(fileType.FilePath);
                matComponent=mlreportgen.report.MATLABVariable(matVar);
                createReport(obj,matComponent,fileName);
            catch ME
                obj.nonCriticalError(ME,fileType);
            end
        end

        function visitMexFile(obj,fileType)
            obj.noWebView(fileType);
        end

        function visitOtherFile(obj,fileType)
            obj.noWebView(fileType);
        end
    end

    methods(Access=protected)

        function nonCriticalError(obj,ME,fileType)
            exception=MException...
            ('evolutions:manage:NoFileView',getString(message...
            ('evolutions:manage:NoFileView')));
            exception=exception.addCause(ME);
            evolutions.internal.session.EventHandler.publish('NonCriticalError',...
            evolutions.internal.ui.GenericEventData(exception));
            obj.noWebView(fileType);
        end

        function noWebView(obj,fileType)
            warningMsg=getString(message...
            ('evolutions:manage:NoFileViewWarning',...
            fileType.FilePath));
            evolutions.internal.session.EventHandler.publish('Warning',...
            evolutions.internal.ui.GenericEventData(struct('msgId',...
            'evolutions:manage:NoFileView','msg',warningMsg)));

            obj.HtmlPath='';
        end

        function createScriptView(obj,fileType)
            fullFileName=fileType.FilePath;
            viewPath=createViewFolder(obj);
            obj.HtmlPath=publish(fullFileName,'evalCode',false,'outputDir',viewPath);
            [~,name,ext]=fileparts(obj.HtmlPath);
            obj.HtmlPath=fullfile(viewPath,[name,ext]);
        end

        function generateWebView(obj,fileType)

            fullFileName=fileType.FilePath;

            obj.HtmlPath=slwebview(fullFileName,...
            'SearchScope','CurrentAndBelow',...
            'LookUnderMasks','all',...
            'FollowLinks','off',...
            'FollowModelReference','off',...
            'RecurseFolder',false,...
            'PackageName',obj.GeneratedFolderName,...
            'PackageFolder',obj.GeneratedFolderPath,...
            'PackagingType','unzipped',...
            'ViewFile',false,...
            'ShowProgressBar',false);

        end

        function generateDiagramView(obj,fileType)
            [~,name]=fileparts(fileType.FilePath);
            if~bdIsLoaded(name)
                load_system(fileType.FilePath);
            end
            diagram=slreportgen.report.Diagram(name);
            createReport(obj,diagram,name);
        end

        function createReport(obj,component,componentName)
            viewPath=createViewFolder(obj);
            viewFileName=sprintf('%s%s',componentName,'.html');
            viewFullFile=fullfile(viewPath,viewFileName);

            report=slreportgen.report.Report('Type','html-file',...
            'OutputPath',viewFullFile);
            report.CompileModelBeforeReporting=false;
            add(report,component);
            close(report);
            obj.HtmlPath=report.OutputPath;

        end

        function viewPath=createViewFolder(obj)
            viewPath=rtwprivate('rtw_create_directory_path',...
            fullfile(obj.GeneratedFolderPath,obj.GeneratedFolderName));
        end
    end
end


