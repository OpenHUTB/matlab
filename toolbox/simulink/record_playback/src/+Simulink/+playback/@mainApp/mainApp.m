


classdef mainApp<handle

    events
UpdatePortEditor
    end

    methods(Static)

        function ret=getController(config)

            ret=Simulink.playback.GUI.getSetGUI(config.BlockId);
        end


        function openGUI(this,config)
            import Simulink.playback.mainApp;
            useExternalBrowser=mainApp.useExternalBrowser();
            if useExternalBrowser
                url=mainApp.getURL(config);
                web(url,'-browser');
            else
                this.Config.OpenType=Simulink.playback.internal.openMainUI(config);
            end
        end


        function url=getURL(config)
            import Simulink.playback.mainApp;
            apiObj=Simulink.sdi.internal.ConnectorAPI.getAPI();
            isDebug=mainApp.debugMode();
            if isDebug
                url=getURL(apiObj,mainApp.DEBUG_URL);
            else
                url=getURL(apiObj,mainApp.REL_URL);
            end
            url=[url,'&blockId=',config.BlockId];
            sigMetadata=get_param(config.BlockPath,'signalMetadata');
            showEmptyState='false';
            if isempty(sigMetadata)
                showEmptyState='true';
            end
            url=[url,'&showEmptyState=',showEmptyState];
            blockName=get_param(config.BlockHandle,'name');
            url=[url,'&blockName=',blockName];
            url=[url,'&AppId=',num2str(config.AppId)];
            url=[url,'&enableSparklineTimeLabels=true'];

        end

    end

    methods





        function this=mainApp(config)

            dispatcherObj=Simulink.sdi.internal.controllers.SDIDispatcher.getDispatcher();
            Simulink.sdi.internal.startConnector;
            this.Config=config;
            this.Dispatcher=dispatcherObj;
            config.Dispatcher=dispatcherObj;
            this.ControllerID=this.Config.BlockId;
            this.AddDataUi=Simulink.playback.addDataUI(config);
            this.Dispatcher.subscribe(...
            [this.ControllerID,'/','showAddUi'],...
            @(arg)showAddDataUi(this,arg));
            this.Dispatcher.subscribe(...
            [this.ControllerID,'/','cancel'],...
            @(arg)cancelUI(this,arg));
            this.Dispatcher.subscribe(...
            [this.ControllerID,'/','exportPlotToFigure'],...
            @(arg)cb_ExportPlotToFigure(this,arg));
            this.Dispatcher.subscribe(...
            [this.ControllerID,'/','openHelpLink'],...
            @(arg)openHelp(this,arg));
            this.Dispatcher.subscribe(...
            [this.ControllerID,'/','addFromEmptyState'],...
            @(arg)addFromEmptyState(this,arg));
            this.Dispatcher.subscribe(...
            [this.ControllerID,'/','getEmptyStateData'],...
            @(arg)getEmptyStateData(this,arg));
            this.Dispatcher.subscribe(...
            [this.ControllerID,'/','browseFile'],...
            @(arg)browseFile(this,arg));
            this.Dispatcher.subscribe(...
            [this.ControllerID,'/','getValidExtensions'],...
            @(arg)getValidExtensions(this,arg));
        end


        function delete(this)
            close(this);
        end


        function close(this,varargin)
            if~isempty(this.Dialog)
                delete(this.Dialog);
                Simulink.playback.GUI.getSetGUI(this.Config.BlockId,[]);
            end
        end


        function bringToFront(this)
            import Simulink.playback.mainApp;
            useExternalBrowser=mainApp.useExternalBrowser();
            if~useExternalBrowser
                if~isempty(this.Dialog)
                    this.Dialog.bringToFront();
                end
            end
        end


        function setSize(this,w,h)
            if~isempty(this.Dialog)
                pos=this.Dialog.CEFWindow.Position;
                this.Config.Position=[pos(1:2),w,h];
                this.Dialog.CEFWindow.Position=this.Config.Position;
            end
        end


        function updatePortEditor(obj)
            notify(obj,'UpdatePortEditor');
        end

    end


    methods(Hidden,Static)

        function isDebug=debugMode(mode)

            mlock;
            persistent pbIsDebug;
            if nargin>0
                pbIsDebug=mode;
            elseif isempty(pbIsDebug)
                pbIsDebug=false;
            end
            isDebug=pbIsDebug;
        end


        function useExternal=useExternalBrowser(mode)

            mlock;
            persistent pbUseExternalBrowser;
            if nargin>0
                pbUseExternalBrowser=mode;
            elseif isempty(pbUseExternalBrowser)
                pbUseExternalBrowser=false;
            end
            useExternal=pbUseExternalBrowser;
        end


        function ret=getDefaultPosition()
            import Simulink.playback.mainApp;

            width=mainApp.DEFAULT_WIDTH;
            height=mainApp.DEFAULT_HEIGHT;

            r=groot;
            screenWidth=r.ScreenSize(3);
            screenHeight=r.ScreenSize(4);
            maxWidth=mainApp.MAX_SIZE_SCALE_FACTOR*screenWidth;
            maxHeight=mainApp.MAX_SIZE_SCALE_FACTOR*screenHeight;
            if maxWidth>0&&width>maxWidth
                width=maxWidth;
            end
            if maxHeight>0&&height>maxHeight
                height=maxHeight;
            end

            xOffset=(screenWidth-width)/2;
            yOffset=(screenHeight-height)/2;

            ret=[xOffset,yOffset,width,height];
        end
    end

    methods(Hidden)

        function showAddDataUi(this,~)
            this.AddDataUi.openGUI();
            this.AddDataUi.bringToFront();
        end

        function onBrowserClose(obj)
            obj.close();
        end


        function cancelUI(this,arg)

            widgetID=arg.data.widgetID;
            if(widgetID=="addDataUI")
                this.AddDataUi.close();
            end
        end


        function cb_ExportPlotToFigure(~,arg)
            try
                copyType='';
                argList={};
                if isfield(arg.data,'copyType')
                    copyType=arg.data.copyType;
                end
                if isfield(arg.data,'displayList')&&~isempty(arg.data.displayList)
                    argList{end+1}='displayList';
                    argList{end+1}=arg.data.displayList;
                end
                engine=Simulink.sdi.Instance.engine;
                engine.exportPlotToFigure(arg.data.clientID,arg.data.axesID,copyType,argList{:});
            catch me
                msgStr=me.message;
                titleStr=getString(message('SDI:sdi:ExportError'));
                okStr=getString(message('SDI:sdi:OKShortcut'));

                info=arg.data;
                Simulink.sdi.internal.controllers.SessionSaveLoad.displayMsgBox(...
                info.appName,...
                titleStr,...
                msgStr,...
                {okStr},...
                0,...
                -1,...
                []);
            end
        end


        function openHelp(~,~)
            helpview('simulink','playbackblock');
        end


        function addFromEmptyState(this,arg)
            blkHandle=getSimulinkBlockHandle(this.Config.BlockPath);

            if(strcmp(get_param(bdroot(blkHandle),'Lock'),'on'))
                errordlg(getString(message('record_playback:errors:PlaybackOpenUIInLockedSystem')));

                clientID=get_param(blkHandle,'clientId');
                argData=struct;
                argData.hideOnlySpinner=true;
                this.Dispatcher.publishToClient(clientID,...
                'mainApp','hideEmptyState',argData);
                return;
            end
            switch arg.data.source
            case 'workspace'
                Simulink.playback.internal.addDataToBlock(blkHandle,...
                'source',arg.data.source,...
                'variables',{arg.data.variables},...
                'isLinked',arg.data.isLinked);
            case 'file'
                Simulink.playback.internal.addDataToBlock(blkHandle,...
                'source',arg.data.source,...
                'filepath',arg.data.filepath,...
                'isLinked',arg.data.isLinked);
            end
        end


        function getEmptyStateData(this,arg)
            data.source=arg.data.source;
            switch arg.data.source
            case 'workspace'
                try
                    wksVars=this.AddDataUi.getBaseWorkSpaceHierarchicalData(this.Config.BlockId);
                catch
                    wksVars=[];
                end
                if isempty(wksVars)
                    return;
                end

                varNames=string({wksVars.RootSource});
                parentIDs=[wksVars.ParentID];
                data.vars=cellstr(varNames(parentIDs==0));
            case 'file'

                fileList=dir('*.*');
                len=length(fileList);
                files=cell(len);
                for idx=1:len
                    fileName=fileList(idx).name;
                    if~isempty(fileName)&&~isfolder(fileName)
                        [~,~,ext]=fileparts(fileName);

                        importer=Simulink.sdi.internal.import.FileImporter.getDefault();
                        if~isempty(ext)&&Simulink.sdi.internal.Util.isFileExtensionValid(fileName,importer.getAllValidFileExtensions())
                            files{idx}=fileName;
                        end
                    end
                end
                files=files(~cellfun('isempty',files));
                if isempty(files)
                    return;
                end
                data.files=files;
            end
            this.Dispatcher.publishToClient(arg.clientID,...
            'mainApp','setEmptyStateData',data);
        end


        function browseFile(this,arg)




            isLinked=arg.data.isLinked;
            if isstruct(arg.data)
                arg.data=arg.data.filename;
            end

            fileData=[];
            if isfield(arg,'data')&&~isempty(arg.data)
                fileData.matFileName=arg.data;
                fileData.status=true;
            else
                addDataUI=this.AddDataUi;
                fileData=addDataUI.openMatFile(addDataUI);
            end


            if fileData.status&&~isempty(fileData.matFileName)
                dataArg=[];
                dataArg.data=[];
                dataArg.data.source='file';
                dataArg.data.filepath=fileData.matFileName;
                dataArg.data.isLinked=isLinked;
                this.addFromEmptyState(dataArg);
            end
        end


        function getValidExtensions(this,arg)
            importer=Simulink.sdi.internal.import.FileImporter.getDefault();
            setupData=struct;
            setupData.validFileExtensions=importer.getAllValidFileExtensions();
            this.Dispatcher.publishToClient(arg.clientID,...
            'mainApp','setValidExtensions',setupData);
        end

    end

    properties(Hidden)
        ClientID;
        ControllerID;
        Dialog;
        Config;
        Dispatcher;
        AddDataUi;
        OpenType;
    end

    properties(Hidden,Constant)
        MAX_SIZE_SCALE_FACTOR=0.8;
        DEFAULT_WIDTH=800;
        DEFAULT_HEIGHT=600;
    end

    properties(Constant)
        AppName='playback';
        REL_URL='toolbox/simulink/record_playback/src/web/playback/playbackview.html';
        DEBUG_URL='toolbox/simulink/record_playback/src/web/playback/playbackview-debug.html';
    end

end
