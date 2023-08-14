


classdef WebGUI<handle


    methods


        function obj=WebGUI(eng,varargin)


            initWebGUI(obj,eng,varargin{:});
        end


        function delete(this)

            this.closeInternal();
        end


        function bRet=isRunning(this)
            import Simulink.sdi.internal.WebGUI;

            if~isempty(WebGUI.qeTestingMode())


                bRet=WebGUI.qeTestingModeRunning();
            elseif~this.UsingSystemBrowser
                bRet=~isempty(this.Dialog)&&...
                isvalid(this.Dialog)&&...
                isOpen(this.Dialog);
            else



                appName='sdi-debug';
                bRet=Simulink.sdi.WebClient.appIsConnected(appName);
            end
        end


        function Close(this,varargin)

            sdiGUI=Simulink.sdi.Instance.getSetGUI();
            if~isempty(this.Dialog)&&~isempty(sdiGUI)
                this.Dialog.onDialogClose();
            end



            if~isempty(varargin)&&ischar(varargin{1})&&strcmpi(varargin{1},'force')
                Simulink.sdi.clear(true);
            end
        end


        function Hide(this)


            if~isempty(this.Dialog)&&isRunning(this)
                this.Dialog.hide();
                this.HDialog.Visible='off';
            end
        end


        function Show(this)

            if this.UsingSystemBrowser
                this.openGUI();
            elseif isempty(this.Dialog)||~isRunning(this)
                this.openGUI();
            else
                this.Dialog.show();
                this.HDialog.Visible='on';
            end
        end


        function bringToFront(this)

            if~isempty(Simulink.sdi.internal.WebGUI.qeTestingMode())




                return;
            elseif this.UsingSystemBrowser
                if~Simulink.sdi.WebClient.appIsConnected('sdi')
                    this.openGUI();
                end
            elseif isempty(this.Dialog)||~isRunning(this)
                this.openGUI();
            else
                this.Dialog.bringToFront();
            end
        end


        function updateGUI(this,varargin)

            if~isempty(varargin)&&isRunning(this)
                if~isempty(this.Dialog)
                    delete(this.Dialog);
                    this.Dialog=[];
                    delete(this.HDialog);
                    this.HDialog=[];
                end
                this.openGUI();
            end
        end


        function changeTab(this,varargin)


            if isempty(varargin)||~isa(varargin{1},'Simulink.sdi.GUITabType')
                return
            end

            this.TabType=varargin{1};
            tabTypeNum=convertTabTypeToNum(this);


            Simulink.sdi.notifyChangeTab(this.SDIEngine.sigRepository,tabTypeNum);
        end


        function result=getDirty(this)
            result=this.dirty;
        end


        function new(~,varargin)
            import Simulink.sdi.internal.controllers.SessionSaveLoad;
            SessionSaveLoad.newSDISession(varargin{:});
        end


        function load(~,varargin)
            import Simulink.sdi.internal.controllers.SessionSaveLoad;
            SessionSaveLoad.loadSDISession(varargin{:});
        end


        function updateSessionInfo(this)


            import Simulink.sdi.internal.controllers.SessionSaveLoad;
            sessionInfo=SessionSaveLoad.getSDISessionInfo();
            this.dirty=Simulink.sdi.sendSessionInfoToClient(...
            'sdi',sessionInfo.Title,...
            sessionInfo.TitleDirty,sessionInfo.FileName);

            title=sessionInfo.Title;
            if this.dirty
                title=sessionInfo.TitleDirty;
            end
            if~this.UsingSystemBrowser&&isRunning(this)&&~isempty(this.Dialog)
                this.Dialog.setTitle(title);
            end
        end


        function plotSignalInComparedRun(this,signalID)
            drr=this.SDIEngine.DiffRunResult;
            if~isempty(drr)
                this.changeTab(Simulink.sdi.GUITabType.CompareRuns);
                comparisonSignalID=this.SDIEngine.getRootComparisonSignalID(signalID);
                if this.SDIEngine.isValidSignalID(comparisonSignalID)
                    Simulink.sdi.setComparisonPlottedSignalAndNotifyClient(...
                    this.SDIEngine.sigRepository,comparisonSignalID);
                end
            end
        end
    end


    methods(Hidden,Static)

        function ret=getSetGeometry(priorWindowPos)
            persistent fixedGeometry
            if nargin>0
                fixedGeometry=priorWindowPos;
                return
            end
            if~isempty(fixedGeometry)
                ret=fixedGeometry;
                return
            end

            width=1200;
            height=800;

            r=groot;
            screenWidth=r.ScreenSize(3);
            screenHeight=r.ScreenSize(4);
            maxWidth=0.8*screenWidth;
            maxHeight=0.8*screenHeight;
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


        function isDebug=debugMode(val)

            mlock;
            persistent SDIIsDebug;
            if nargin>0
                isOpen=Simulink.sdi.Instance.isSDIRunning();
                Simulink.sdi.Instance.close();
                Simulink.sdi.Instance.getSetGUI([]);
                SDIIsDebug=val;
                if isOpen
                    Simulink.sdi.Instance.open();
                end
            elseif isempty(SDIIsDebug)
                SDIIsDebug=false;
            end
            isDebug=SDIIsDebug;
        end


        function ret=useCEF(val)
            mlock;
            persistent UsingCEF;
            if nargin>0
                isOpen=Simulink.sdi.Instance.isSDIRunning();
                Simulink.sdi.Instance.close();
                Simulink.sdi.Instance.getSetGUI([]);
                UsingCEF=val;
                if isOpen
                    Simulink.sdi.Instance.open();
                end
            elseif isempty(UsingCEF)
                UsingCEF=true;
            end
            ret=UsingCEF;
        end



        function ret=qeTestingMode(fcn)
            mlock;
            persistent QETestingMode;
            if nargin>0
                QETestingMode=fcn;
            elseif isempty(QETestingMode)
                QETestingMode=[];
            end
            ret=QETestingMode;
        end

        function ret=qeTestingModeRunning(val)
            mlock;
            persistent QETestingModeRunning;
            if nargin>0
                QETestingModeRunning=val;
            elseif isempty(QETestingModeRunning)
                QETestingModeRunning=false;
            end
            ret=QETestingModeRunning;
        end

        function sendSessionInfo(appName)
            sessionInfo=Simulink.sdi.internal.controllers.SessionSaveLoad.getSDISessionInfo('appName',appName);
            Simulink.sdi.sendSessionInfoToClient(...
            appName,sessionInfo.Title,...
            sessionInfo.TitleDirty,sessionInfo.FileName);
        end


        function url=getURL()
            import Simulink.sdi.internal.WebGUI;

            appendChar='?';
            function ret=buildUrl(option)
                ret=[url,appendChar,option];
                appendChar='&';
            end

            if WebGUI.debugMode()
                url=WebGUI.DEBUG_URL;
            else
                url=WebGUI.SDI_REL_URL;
            end


            if Simulink.sdi.slicer()
                url=buildUrl(WebGUI.SLICER);
            end


            if Simulink.sdi.enableBusRenaming()
                url=buildUrl(WebGUI.BUS_RENAMING);
            end


            if Simulink.sdi.enableSDIVideo()>1
                url=buildUrl(WebGUI.SDI_VIDEO);
            end


            if Simulink.sdi.enableBAGImport()
                url=buildUrl(WebGUI.BAG_IMPORT);
            end


            if Simulink.sdi.enableUseSystemBrowser()
                url=buildUrl(WebGUI.BROWSER_CONFIG);
            end


            if Simulink.sdi.enableDomainGrouping()
                url=buildUrl(WebGUI.ENABLE_DOMAIN_GROUPING);
            end


            if Simulink.sdi.enableComparisonReportSorting()
                url=buildUrl(WebGUI.ENABLE_COMPARISON_REPORT_SORTING);
            end

            if Simulink.sdi.enableComparisonReportGrouping()
                url=buildUrl(WebGUI.ENABLE_COMPARISON_REPORT_GROUPING);
            end


            comparisonSettingsVal=sprintf('comparisonSettings=%d',Simulink.sdi.enableSDIComparisonSettings());
            url=buildUrl(comparisonSettingsVal);


            if Simulink.sdi.enableXYLimits()
                url=buildUrl(WebGUI.ENABLE_XYLIMITS);
            end


            if Simulink.sdi.enableZoomArea()
                url=buildUrl(WebGUI.ENABLE_ZOOM_AREA);
            end


            if Simulink.sdi.enableSparklineTimeLabels()
                url=buildUrl(WebGUI.ENABLE_SPARKLINE_TIME_LABELS);
            end


            if Simulink.sdi.enableImportDialogEnhancements()
                url=buildUrl(WebGUI.ENABLE_IMPORT_DIALOG_ENHANCEMENTS);
            end

            if Simulink.sdi.enableVizGalleryEnhancements()
                url=buildUrl(WebGUI.ENABLE_VIZGALLERY_ENHANCEMENTS);
            end


            if Simulink.sdi.enableResponsiveSidebar()
                url=buildUrl(WebGUI.ENABLE_RESPONSIVE_SIDEBAR);
            end


            if Simulink.sdi.enableResponsiveToolbar()
                url=buildUrl(WebGUI.ENABLE_RESPONSIVE_TOOLBAR);
            end

            apiObj=Simulink.sdi.internal.ConnectorAPI.getAPI();
            url=getURL(apiObj,url);
        end
    end


    methods(Access=protected)


        function initWebGUI(obj,eng,varargin)
            Simulink.sdi.internal.startConnector;
            obj.SDIEngine=eng;




            sigToSelect=0;
            if length(varargin)>1
                sigToSelect=varargin{2};
            end


            sessionInfo=...
            Simulink.sdi.internal.controllers.SessionSaveLoad.getSDISessionInfo();
            obj.dirty=Simulink.sdi.cacheSessionInfo('sdi',sessionInfo.Title,sessionInfo.TitleDirty,sessionInfo.FileName,int32(sigToSelect),convertTabTypeToNum(obj));
            obj.UsingSystemBrowser=Simulink.sdi.getUseSystemBrowser;


            if~isRunning(obj)
                obj.openGUI();
            end
        end


        function openGUI(this)

            fw=Simulink.sdi.internal.AppFramework.getSetFramework();
            maxSigLimit=fw.getMaxSigsPref();
            Simulink.sdi.internalSetMaxSigLimit(maxSigLimit);


            import Simulink.sdi.internal.WebGUI;
            import matlab.internal.lang.capability.Capability;

            url=WebGUI.getURL();
            this.ReadyToShowSubscription=message.subscribe(WebGUI.READY_TO_SHOW_CHANNEL,@(arg)onReadyToShow(this,arg));

            qeFcn=WebGUI.qeTestingMode();
            if~isempty(qeFcn)


                qeFcn();
            elseif this.UsingSystemBrowser
                web(url,'-browser');
            else
                title=getString(message('SDI:sdi:ToolName'));
                useCEF=WebGUI.useCEF();
                debugMode=WebGUI.debugMode();


                if Capability.isSupported(Capability.LocalClient)
                    useReadyToShow=true;
                else
                    useReadyToShow=false;
                end

                this.Dialog=Simulink.HMI.BrowserDlg(...
                url,title,Simulink.sdi.internal.WebGUI.getSetGeometry(),...
                [],useCEF,debugMode,...
                @()onBrowserClose(this),...
                useReadyToShow);
                this.Dialog.CustomPreCloseCB=@()clientCloseHandshake(this);
            end
            this.HDialog=Simulink.sdi.internal.WebGUITestingProps;
            this.HDialog.Visible='on';
            this.updateSessionInfo;
        end

        function flag=clientCloseHandshake(this)
            this.publishNotifyClose();
            this.waitForClientResponse();



            flag=true;
        end

        function cb_ClientCleanupAck(this,clientID)

            if strcmp(num2str(clientID),this.ClientID)
                this.ClientCleanupAck=true;
            end
        end
    end


    methods(Access=private)

        function tabTypeNum=convertTabTypeToNum(this)
            switch this.TabType
            case Simulink.sdi.GUITabType.InspectSignals
                tabTypeNum=0;
            otherwise
                tabTypeNum=1;
            end
        end


        function closeInternal(this)


            if~isempty(this.Dialog)
                delete(this.Dialog);
                this.Dialog=[];
                delete(this.HDialog);
                this.HDialog=[];
            end

            Simulink.sdi.Instance.getSetGUI([]);
            notify(this,'GUICloseEvent',Simulink.sdi.internal.SDIEvent('GUICloseEvent'));
        end
    end


    methods(Hidden)

        function onBrowserClose(this)
            Simulink.sdi.internal.WebGUI.getSetGeometry(this.Dialog.WindowPosOnClose);
            Simulink.sdi.Instance.getSetGUI([]);
            Simulink.sdi.Instance.getSetGUIOpenningFlag(false);
        end


        function onReadyToShow(this,evt)
            if isvalid(this)&&~isempty(this.Dialog)
                this.ClientID=num2str(evt.clientID);
                this.Dialog.show();
            end
            message.unsubscribe(this.ReadyToShowSubscription);
            this.ReadyToShowSubscription=[];
            if~isempty(this.ReadyToShowHandler)&&...
                isa(this.ReadyToShowHandler,'function_handle')
                this.ReadyToShowHandler();
            end
        end


        function setOnReadyToShow(this,cb)
            this.ReadyToShowHandler=cb;
        end

        function publishNotifyClose(this)
            dispatcherObj=Simulink.sdi.internal.controllers.SDIDispatcher.getDispatcher();


            dispatcherObj.registerRemove('WebGUI',@(arg)cb_ClientCleanupAck(this,arg));
            dispatcherObj.publishToClient(this.ClientID,'WebGUI','clientDestroy',[]);
        end

        function waitForClientResponse(this)
            MAX_TRIES=20;
            nTries=0;
            while isempty(this.ClientCleanupAck)&&nTries<MAX_TRIES
                pause(0.1);
                nTries=nTries+1;
            end
        end
    end


    properties(Access='public',SetObservable)
        dirty=false;
        ClearOnClose=true;
    end


    properties(SetAccess=protected)
        SDIEngine;
        UsingSystemBrowser;
        ReadyToShowSubscription=[];
        ReadyToShowHandler=[];
    end


    properties(Hidden)
        Dialog;
        ClientID;
        ClientCleanupAck;


        HDialog;
        TabType=Simulink.sdi.GUITabType.InspectSignals;
    end


    events
        GUICloseEvent;
    end


    properties(Constant)
        SDI_REL_URL='toolbox/shared/sdi/web/MainView/sdi.html';
        DEBUG_URL='toolbox/shared/sdi/web/MainView/sdi-debug.html';
        READY_TO_SHOW_CHANNEL='/sdi/readyToShow';
        STREAMOUT='streamOut=true';
        SLICER='slicer=true';
        BUS_RENAMING='busRenaming=true';
        SDI_VIDEO='video=true';
        BAG_IMPORT='bagImport=true';
        BROWSER_CONFIG='browserConfig=true';
        ENABLE_DOMAIN_GROUPING='enableDomainGrouping=true';
        ENABLE_COMPARISON_REPORT_SORTING='enableComparisonReportSorting=true';
        ENABLE_COMPARISON_REPORT_GROUPING='enableComparisonReportGrouping=true';
        ENABLE_XYLIMITS='enableXYLimits=true';
        ENABLE_TRENDLINE_OVERLAY='enableTrendlineOverlay=true';
        ENABLE_XY_LEGEND_TOOLTIP='enableXYLegendTooltip=true';
        ENABLE_ZOOM_AREA='enableZoomArea=true';
        ENABLE_SPARKLINE_TIME_LABELS='enableSparklineTimeLabels=true';
        ENABLE_IMPORT_DIALOG_ENHANCEMENTS='enableImportDialogEnhancements=true';
        ENABLE_RESPONSIVE_SIDEBAR='enableResponsiveSidebar=true';
        ENABLE_RESPONSIVE_TOOLBAR='enableResponsiveToolbar=true';
        ENABLE_VIZGALLERY_ENHANCEMENTS='enableVizGalleryEnhancements=true';
    end

end


