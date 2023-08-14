classdef WebGUI<handle




    properties(Access='public',SetObservable)
    end

    properties(SetAccess=protected)
        SDIEngine;
        UsingSystemBrowser;
        ReadyToShowSubscription=[];
        ReadyToShowHandler=[];
    end

    properties(Hidden)
        Dialog;
    end

    events
        GUICloseEvent;
    end

    properties(Constant)
        SL_REL_URL='toolbox/signal/sigappsshared/web/MainView/sl.html';
        SL_DEBUG_URL='toolbox/signal/sigappsshared/web/MainView/sl-debug.html';
        SIGLABELER_URL_SUFFIX='?sigAnalyzerApp=true';
        SIGLABELER_SIGNALTREETABLE_MODELID_SUFFIX='&signalTreeTableModelID=';
        WAVELETOOLBOX_URL_SUFFIX='&waveletToolbox=true';
        STATISTICSTOOLBOX_URL_SUFFIX='&statisticsToolbox=true';
        AUDIOTOOLBOX_URL_SUFFIX='&audioToolbox=true';
        AUDIOPLAYBACK_URL_SUFFIX='&audioPlayback=true';
        TESTALLDOMAINS_URL_SUFFIX='&testAllDomains=true';
        READY_TO_SHOW_CHANNEL='/signallabeler/readyToShow';
    end



    methods
        function obj=WebGUI(eng,varargin)
            initWebGUI(obj,eng,varargin{:});
        end


        function delete(this)

            this.Close();
        end


        function bRet=isRunning(this)
            import signal.labeler.WebGUI;

            if~this.UsingSystemBrowser
                bRet=~isempty(this.Dialog)&&isvalid(this.Dialog)&&isOpen(this.Dialog);
            else
                appName=WebGUI.getAppName();
                bRet=Simulink.sdi.WebClient.appIsConnected(appName);
            end
        end


        function Close(this,varargin)


            if~isempty(this.Dialog)
                delete(this.Dialog);
                this.Dialog=[];


                wsb=internal.matlab.workspace.peer.PeerWorkspaceBrowserFactory.createWorkspaceBrowser('signal.labeler.FilteredWorkspace','/SigLabelerWSBChannel');
                delete(wsb);


                this.clearLabelerAppData();
            end

            signal.labeler.Instance.getSetGUI([]);

        end


        function Hide(this)


            if~isempty(this.Dialog)&&isRunning(this)
                this.Dialog.hide();
            end
        end


        function Show(this)

            if this.UsingSystemBrowser
                this.openGUI();
            elseif isempty(this.Dialog)||~isRunning(this)
                this.openGUI();
            else
                this.Dialog.show();
            end
        end


        function bringToFront(this)

            import signal.labeler.WebGUI;
            if this.UsingSystemBrowser
                appName=WebGUI.getAppName();
                if~Simulink.sdi.WebClient.appIsConnected(appName)
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
                end
                this.openGUI();
            end
        end


        function updateSessionInfo(this)


            title=getString(message('signal:signallabeler:AppTitle'));

            if~this.UsingSystemBrowser&&isRunning(this)&&~isempty(this.Dialog)
                this.Dialog.setTitle(title);
            end
        end

        function updateAppTitle(this,dirtyStatus)


            if dirtyStatus
                title=getString(message('signal:signallabeler:AppTitleDirty'));
            else
                title=getString(message('signal:signallabeler:AppTitle'));
            end

            if~this.UsingSystemBrowser&&isRunning(this)&&~isempty(this.Dialog)
                this.Dialog.setTitle(title);
            end

        end
    end



    methods(Hidden,Static)
        function appName=getAppName()
            import signal.labeler.WebGUI;
            appName='sl';
            if WebGUI.debugMode()
                appName='sl-debug';
            end
        end


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


        function isTest=testMode(val)



            mlock;
            persistent IsTest;
            if nargin>0
                IsTest=val;
            elseif isempty(IsTest)
                IsTest=false;
            end
            isTest=IsTest;
        end


        function isDebug=debugMode(val)

            mlock;
            persistent IsDebug;
            if nargin>0
                isOpen=signal.labeler.Instance.isSignalLabelerRunning();
                signal.labeler.Instance.close();
                signal.labeler.Instance.getSetGUI([]);
                IsDebug=val;
                if isOpen
                    signal.labeler.Instance.open();
                end
            elseif isempty(IsDebug)
                IsDebug=false;
            end
            isDebug=IsDebug;
        end


        function flag=haveWaveletToolbox(val)
            mlock;
            persistent bhaveWaveletToolbox;
            if nargin>0
                isOpen=signal.labeler.Instance.isSignalLabelerRunning();
                signal.labeler.Instance.close();
                signal.labeler.Instance.getSetGUI([]);
                bhaveWaveletToolbox=val;
                if isOpen
                    signal.labeler.Instance.open();
                end
            elseif isempty(bhaveWaveletToolbox)
                bhaveWaveletToolbox=false;
            end
            flag=bhaveWaveletToolbox;
        end




        function flag=testAllDomainsMode(val)
            mlock;
            persistent IsTestAllDomainsModeOn;
            if nargin>0
                isOpen=signal.labeler.Instance.isSignalLabelerRunning();
                signal.labeler.Instance.close();
                signal.labeler.Instance.getSetGUI([]);
                IsTestAllDomainsModeOn=val;
                if isOpen
                    signal.labeler.Instance.open();
                end
            elseif isempty(IsTestAllDomainsModeOn)
                IsTestAllDomainsModeOn=false;
            end
            flag=IsTestAllDomainsModeOn;
        end


        function ret=useCEF(val)
            mlock;
            persistent UsingCEF;
            if nargin>0
                isOpen=signal.labeler.Instance.isSignalLabelerRunning();
                signal.labeler.Instance.close();
                signal.labeler.Instance.getSetGUI([]);
                UsingCEF=val;
                if isOpen
                    signal.labeler.Instance.open();
                end
            elseif isempty(UsingCEF)
                UsingCEF=true;
            end
            ret=UsingCEF;
        end


        function url=getURL()
            import signal.labeler.WebGUI;
            apiObj=signal.labeler.ConnectorAPI.getAPI();

            if WebGUI.debugMode()
                url=getURL(apiObj,WebGUI.SL_DEBUG_URL);
            else
                url=getURL(apiObj,WebGUI.SL_REL_URL);
            end
        end
    end



    methods(Access=protected)
        function initWebGUI(obj,eng,varargin)
            signal.labeler.startConnector;
            obj.SDIEngine=eng;

            obj.UsingSystemBrowser=Simulink.sdi.getUseSystemBrowser;


            if~isRunning(obj)
                obj.openGUI();
            end
        end


        function openGUI(this)

            import signal.labeler.WebGUI;
            import matlab.internal.lang.capability.Capability;
            apiObj=signal.labeler.ConnectorAPI.getAPI();

            if WebGUI.debugMode()
                url=getURL(apiObj,[WebGUI.SL_DEBUG_URL,WebGUI.SIGLABELER_URL_SUFFIX]);
            else
                url=getURL(apiObj,[WebGUI.SL_REL_URL,WebGUI.SIGLABELER_URL_SUFFIX]);
            end

            if WebGUI.haveWaveletToolbox()
                url=[url,WebGUI.WAVELETOOLBOX_URL_SUFFIX];
            end


            if audio.labeler.internal.AudioModeController.isAudioToolboxInstalled()
                url=[url,WebGUI.AUDIOTOOLBOX_URL_SUFFIX];
                if audio.labeler.internal.AudioModeController.isAudioPlaybackSupported()


                    url=[url,WebGUI.AUDIOPLAYBACK_URL_SUFFIX];
                end
            end

            if~isempty(ver('stats'))&&license('test','Statistics_Toolbox')
                url=[url,WebGUI.STATISTICSTOOLBOX_URL_SUFFIX];
            end

            if WebGUI.testAllDomainsMode()
                url=[url,WebGUI.TESTALLDOMAINS_URL_SUFFIX];
            end

            url=[url,WebGUI.SIGLABELER_SIGNALTREETABLE_MODELID_SUFFIX,signal.labeler.controllers.SignalTableController.getController().getSignalTreeTableMdomDataModelID()];

            if this.UsingSystemBrowser
                web(connector.applyNonce(url),'-browser');
            else
                title=DAStudio.message('SDI:labeler:ToolName');
                useCEF=WebGUI.useCEF();
                debugMode=WebGUI.debugMode();
                testMode=WebGUI.testMode();
                this.ReadyToShowSubscription=message.subscribe(WebGUI.READY_TO_SHOW_CHANNEL,@(e,s)onReadyToShow(this));


                if Capability.isSupported(Capability.LocalClient)
                    useReadyToShow=true;
                else
                    useReadyToShow=false;
                end
                this.Dialog=Simulink.HMI.BrowserDlg(...
                url,title,WebGUI.getSetGeometry(),...
                [],useCEF,debugMode|testMode,...
                @()onBrowserClose(this),...
                useReadyToShow);
                this.Dialog.CustomPreCloseCB=@()onBrowserPreClose(this);
            end
            this.updateSessionInfo;
        end


        function clearLabelerAppData(~)

            signal.labeler.SignalUtilities.deleteAllSLRuns();


            model=signal.labeler.models.LabelDataRepository.getModel();
            resetModel(model);
            model=signal.labeler.models.FastLabelDataRepository.getModel();
            resetModel(model);
            model=signal.labeler.models.DashboardDataRepository.getModel();
            resetModel(model);
            model=signal.labeler.models.FeatureExtractionDataRepository.getModel();
            resetModel(model);

            if audio.labeler.internal.AudioModeController.isAudioToolboxInstalled()
                audioController=audio.labeler.internal.AudioModeController.getInstance();
                resetModels(audioController);
            end
        end
    end



    methods(Hidden)
        function onBrowserClose(this)
            signal.labeler.WebGUI.getSetGeometry(this.Dialog.WindowPosOnClose);
            signal.labeler.Instance.getSetGUI([]);
            signal.labeler.Instance.getSetGUIOpenningFlag(false);
        end


        function flag=onBrowserPreClose(this)

            model=signal.labeler.models.LabelDataRepository.getModel();
            if model.isDirty()
                message.publish('/sdi2/displayMsgBoxSignalLabeler',struct);
            else
                this.completeCloseOperation();
            end
            flag=false;
        end


        function completeCloseOperation(this)




            this.clearLabelerAppData();
            this.SDIEngine.publishUpdateLabelsNotification();
            this.Dialog.completeCloseOperation();
        end


        function onReadyToShow(this)
            if isvalid(this)&&~isempty(this.Dialog)
                this.Dialog.show();
                message.unsubscribe(this.ReadyToShowSubscription);
                this.ReadyToShowSubscription=[];
            end
        end
    end

end