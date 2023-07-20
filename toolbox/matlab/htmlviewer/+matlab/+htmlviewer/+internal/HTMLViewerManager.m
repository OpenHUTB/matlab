classdef HTMLViewerManager<handle





    properties(Access=private)
DataModel
MessageService
    end

    properties(SetAccess=protected,Hidden)
        IsServicesInitialized=false
    end

    properties(Access=private,Constant,Hidden)
        HTMLTextChannel='requestHTMLText'
        TitleChannel='requestTitle'
        CloseChannel='requestClose'
        VisibleChannel='receiveVisibility'
        HTMLPageOpenChannel='receiveHTMLPageOpenData'
        HTMLTextStatus='IsHTMLTextReceived'
        TitleStatus='IsTitleReceived'
        CloseStatus='IsCloseCompleted'
    end

    methods(Static)
        function obj=getInstance()
            mlock;


            persistent instance
            if isempty(instance)||~isvalid(instance)
                instance=matlab.htmlviewer.internal.HTMLViewerManager();
            end
            obj=instance;
        end
    end

    methods(Access=protected)
        function obj=HTMLViewerManager()
            obj.DataModel=matlab.htmlviewer.internal.DataModel();
        end
    end

    methods(Hidden)
        function viewer=load(obj,htmlInput,options)
            htmlInput=obj.validateInput(htmlInput);
            if matlab.htmlviewer.internal.isHTMLViewer

                obj.initializeCoreServices();
                [options.FileName,options.HTMLPagePath,options.IsTextHTMLInput]=obj.addHTMLPageLocationToSecureList(htmlInput);
                if options.NewTab
                    viewer=obj.createViewerHandle(options);
                else
                    if~obj.isActiveHandleInstanceExists()
                        options.NewTab=1;
                    end
                    viewer=obj.getActiveViewer(htmlInput,options);
                end

                viewer.Input=htmlInput;
            else

                options.HTMLPagePath=string;
                options.FileName=string;
                options.IsTextHTMLInput=obj.isStreamingTextInput(htmlInput);
                obj.checkIfWebBrowserIsClosed();
                if options.NewTab
                    viewer=obj.createViewerHandle(options);
                else
                    viewer=obj.getActiveViewer(htmlInput,options);
                end

                viewer.Input=htmlInput;
            end
        end

        function htmlFile=validateInput(obj,htmlFile)
            htmlFile=erase(htmlFile,obj.getSlashPattern());
            if obj.isStreamingTextInput(htmlFile)||obj.isLocalhostInput(htmlFile)||(htmlFile=="")
                return
            elseif obj.isExternalInput(htmlFile)

                throwAsCaller(MException(message('htmlviewer:messages:UnsupportedExternalInput')));
            else

                htmlFile=erase(htmlFile,obj.getFilePattern());
                htmlFile=obj.resolvePathSeparator(htmlFile);
                htmlFile=obj.resolveFilePath(htmlFile);
                anchorlessHtmlFile=erase(htmlFile,obj.getAnchorPattern());
                if~isfile(anchorlessHtmlFile)

                    throwAsCaller(MException(message('htmlviewer:messages:HTMLFileNotFound',anchorlessHtmlFile)));
                else

                    [~,~,extension]=fileparts(anchorlessHtmlFile);
                    if isempty(extension)||~obj.isValidExtension(extension)
                        throwAsCaller(MException(message('htmlviewer:messages:UnsupportedFileExtension')));
                    end
                end
            end
        end

        function cacheOpenRequest(obj,viewer,options)
            htmlPageOpenRequest=struct('HTMLFile',viewer.Input,'Options',options,'Handle',viewer);

            obj.DataModel.addToOpenRequestQueue(htmlPageOpenRequest);
        end

        function requestHTMLPageOpen(obj,payload)
            obj.MessageService.publishData(obj.HTMLPageOpenChannel,payload);
        end

        function publishPendingOpenRequests(obj)
            requestQueue=obj.DataModel.getOpenRequestQueue();

            for entry=1:length(requestQueue)
                currentRequest=requestQueue{entry};


                currentRequest.Handle.updateInputArguments(currentRequest.Options);
                currentRequest.Handle.open();
            end
        end

        function[fileName,htmlPagePath,isTextHTMLInput]=addHTMLPageLocationToSecureList(obj,htmlFile)
            fileName=string;
            htmlPagePath=htmlFile;
            isTextHTMLInput=obj.isStreamingTextInput(htmlFile);
            if isTextHTMLInput

                htmlPagePath=erase(htmlPagePath,obj.getTextPattern());
            end
            if isTextHTMLInput||(htmlFile=="")
                return
            end
            if obj.isLocalhostInput(htmlFile)
                [filePath,name,extension]=fileparts(htmlFile);
                fileName=strcat(name,extension);
                fileName=extractBefore(fileName,"?");
                return
            end

            [filePath,name,extension]=fileparts(htmlFile);
            if startsWith(extension,'.txt')

                isTextHTMLInput=true;
                htmlPagePath=strcat('<pre>',fileread(htmlFile),'</pre>');
                return
            end
            fileName=strcat(name,extension);

            filePath=erase(filePath,obj.getFilePattern());
            fileLocationHash=fullfile(filePath,name);
            staticRoute=obj.DataModel.getHTMLPageStaticPath(fileLocationHash);
            if~isempty(staticRoute)

                htmlPagePath=fullfile(staticRoute,fileName);
                return
            end


            [staticRoute,routeName]=obj.addHTMLPageLocationOnStaticPath(filePath);
            htmlPagePath=fullfile(staticRoute,fileName);
            obj.DataModel.storeHTMLPageStaticPath(fileLocationHash,staticRoute);
            obj.DataModel.storeRouteName(routeName);
        end

        function status=isClientReady(obj)
            status=false;
            if obj.MessageService.IsClientMessageServiceStarted
                status=true;
            end
        end

        function htmlText=getHTMLText(obj,viewerID)
            payload=struct('ViewerID',viewerID);
            obj.DataModel.resetHTMLTextCache();
            obj.MessageService.publishData(obj.HTMLTextChannel,payload);

            obj.startTimerAndWaitUntilDataIsReceived(obj.HTMLTextStatus);

            htmlText=obj.DataModel.getActiveHTMLText();
        end

        function updateHTMLTextData(obj,htmlText)
            obj.DataModel.setActiveHTMLText(htmlText);
        end

        function title=getTitle(obj,viewerID)
            payload=struct('ViewerID',viewerID);
            obj.DataModel.resetTitleCache();
            obj.MessageService.publishData(obj.TitleChannel,payload);

            obj.startTimerAndWaitUntilDataIsReceived(obj.TitleStatus);

            title=obj.DataModel.getActiveTitle();
        end

        function updateTitleData(obj,title)
            obj.DataModel.setActiveTitle(title);
        end

        function setVisibility(obj,viewerID,status)
            payload=struct('ViewerID',viewerID,'Visible',status);

            obj.MessageService.publishData(obj.VisibleChannel,payload);
        end

        function viewer=getLastActiveViewer(obj)
            viewer=obj.DataModel.getLastActiveViewerHandle();
        end

        function updateLastActiveViewerID(obj,viewerID)
            obj.DataModel.setLastActiveViewerID(viewerID);
        end

        function close(obj,viewerID)
            payload=struct('ViewerID',viewerID);
            obj.DataModel.setCloseCompletion(false);

            obj.MessageService.publishData(obj.CloseChannel,payload);

            obj.startTimerAndWaitUntilDataIsReceived(obj.CloseStatus);
        end

        function onHTMLPageCloseCompletion(obj,viewerID)
            obj.DataModel.setCloseCompletion(true);
            viewer=obj.DataModel.getViewerHandle(viewerID);

            if~isempty(viewer)&&viewer.isvalid
                viewer.updateOnClose();
                obj.DataModel.removeViewerHandle(viewerID);

                viewer.delete;
            end
            obj.checkIfHTMLViewerIsClosed();
        end

        function processMatlabColonRequest(obj,data)
            runCommand=obj.getMatlabColonRunCommand(data);
            eval(runCommand);
        end
    end

    methods(Hidden)

        function webInputOptions=getWebInputOptions(~,newTab,showToolbar)
            webInputOptions={};

            if newTab
                webInputOptions{end+1}='-new';
            end
            if~showToolbar
                webInputOptions{end+1}='-notoolbar';
            end
        end

        function onWebBrowserPageCloseCompletion(obj,viewerID)
            viewer=obj.DataModel.getViewerHandle(viewerID);
            if~isempty(viewer)&&viewer.isvalid
                obj.DataModel.removeViewerHandle(viewerID);
                obj.DataModel.setLastActiveViewerID([]);

                viewer.delete;
                obj.checkIfWebBrowserIsClosed();
            end
        end
    end

    methods(Access=protected,Static,Hidden)
        function uuid=createUUID()
            [~,uuid]=fileparts(tempname);
        end

        function pattern=getSlashPattern()
            pattern=regexpPattern("^\s*(\\|\/)*");
        end

        function pattern=getTextPattern()
            pattern=regexpPattern("^text:(\\|\/)*","IgnoreCase",true);
        end

        function pattern=getFilePattern()
            pattern=regexpPattern("^file:(\\|\/)*","IgnoreCase",true);
        end

        function pattern=getLocalhostPattern()
            pattern=regexpPattern("^(https|http):(\\|\/)*127\.0\.0\.1:","IgnoreCase",true);
        end

        function pattern=getExternalURLPattern()
            pattern=regexpPattern("^((https|http):(\\|\/)*)|(www\.)","IgnoreCase",true);
        end

        function pattern=getValidFileExtensionPattern()
            pattern=regexpPattern("^.(htm|html|txt)","IgnoreCase",true);
        end

        function pattern=getAnchorPattern()
            pattern=regexpPattern("#.*","IgnoreCase",true);
        end

        function pattern=getMatlabColonPattern()
            pattern=regexpPattern("^\s*matlab:\s*","IgnoreCase",true);
        end

        function fullpath=getWhich(htmlFile)
            try
                fullpath=which(htmlFile,'-all');
            catch
                fullpath='';
            end
        end

        function htmlFile=resolvePathSeparator(htmlFile)
            if ispc
                htmlFile=replace(htmlFile,'/',filesep);
                drivePattern=lettersPattern(1)+":";


                if startsWith(htmlFile,drivePattern)
                    return
                end
            else
                htmlFile=replace(htmlFile,'\',filesep);
            end
            if contains(htmlFile,filesep)

                htmlFile=sprintf('%s%s%s',filesep,filesep,htmlFile);
            end
        end
    end

    methods(Access=protected)
        function initializeCoreServices(obj)
            if~obj.IsServicesInitialized
                obj.IsServicesInitialized=true;

                connector.ensureServiceOn;

                obj.MessageService=matlab.htmlviewer.internal.MessageService();
                obj.MessageService.startService();

                obj.DataModel.resetDataCache();
            end

            obj.MessageService.pingClient();
        end

        function viewer=createViewerHandle(obj,options)
            options.ViewerID=obj.createUUID();
            options.RequestID=obj.createUUID();
            viewer=matlab.htmlviewer.HTMLViewer(options);
            obj.DataModel.storeViewerHandle(viewer,options.ViewerID);
            obj.updateLastActiveViewerID(options.ViewerID);
        end

        function viewer=getActiveViewer(obj,htmlFile,options)
            if obj.isActiveHandleInstanceExists
                viewer=obj.DataModel.getLastActiveViewerHandle();
                if~isempty(htmlFile)
                    options.RequestID=obj.createUUID();
                    viewer.updateInputArguments(options);
                end
            else
                viewer=obj.createViewerHandle(options);
            end
        end

        function status=isActiveHandleInstanceExists(obj)
            status=false;
            viewer=obj.DataModel.getLastActiveViewerHandle();
            if~isempty(viewer)&&viewer.isTabOpen
                status=true;
            end
        end

        function[staticRoute,routeName]=addHTMLPageLocationOnStaticPath(obj,folderPath)
            routeName=strcat('HTMLPage',strrep(obj.createUUID(),'_',''));

            staticRoute=string(connector.addStaticContentOnPath(routeName,folderPath));
        end

        function status=isStreamingTextInput(obj,htmlInput)
            status=false;
            if startsWith(htmlInput,obj.getTextPattern())
                status=true;
            end
        end

        function status=isLocalhostInput(obj,htmlInput)
            status=false;
            if startsWith(htmlInput,obj.getLocalhostPattern())
                status=true;
            end
        end

        function status=isExternalInput(obj,htmlInput)
            status=false;
            if startsWith(htmlInput,obj.getExternalURLPattern())
                status=true;
            end
        end

        function status=isValidExtension(obj,extension)
            inputFileExtensionPattern=obj.getValidFileExtensionPattern();
            status=matches(extension,inputFileExtensionPattern);
        end

        function htmlFile=resolveFilePath(obj,htmlFile)
            fullpath=obj.getWhich(htmlFile);

            if~isempty(fullpath)
                if iscell(fullpath)
                    for i=1:length(fullpath)
                        if isfile(fullpath{i})
                            htmlFile=fullpath{i};
                            return;
                        end
                    end
                elseif isfile(fullpath)

                    htmlFile=fullpath;
                end
            else


                fullpath=fullfile(pwd,htmlFile);
                if isfile(fullpath)
                    htmlFile=fullpath;
                end
            end
        end

        function startTimerAndWaitUntilDataIsReceived(obj,property)
            t=timer(...
            'Period',0.1,...
            'ExecutionMode','fixedSpacing',...
            'ObjectVisibility','off',...
            'TimerFcn',{@obj.isDataReceived,property});

            t.TasksToExecute=50;
            start(t);


            wait(t);
            delete(t);
        end

        function isDataReceived(obj,mTimer,~,property)
            if obj.DataModel.(property)
                stop(mTimer);
            end
        end

        function checkIfHTMLViewerIsClosed(obj)
            activeViewer=obj.getLastActiveViewer();
            if isempty(activeViewer)


                obj.DataModel.cleanupOnHTMLViewerClose();
            end
        end

        function runCommand=getMatlabColonRunCommand(obj,data)
            matlabPattern=obj.getMatlabColonPattern();
            runCommand=erase(data,matlabPattern);
        end
    end

    methods(Access=protected)

        function checkIfWebBrowserIsClosed(obj)
            activeViewer=matlab.htmlviewer.internal.getActiveWindow();
            if isempty(activeViewer)


                obj.DataModel.resetDataCache();
            end
        end
    end
end