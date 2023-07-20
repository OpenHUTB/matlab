



classdef WebGUI<handle


    methods


        function obj=WebGUI(eng,varargin)
            initWebGUI(obj,eng,varargin{:});
        end


        function delete(this)
            this.Close();
        end


        function bRet=isRunning(this)
            import signal.analyzer.WebGUI;

            if~this.UsingSystemBrowser
                bRet=~isempty(this.Dialog)&&...
                isvalid(this.Dialog)&&...
                isOpen(this.Dialog);
            else
                appName='sa';
                if WebGUI.debugMode()
                    appName='sa-debug';
                end
                bRet=Simulink.sdi.WebClient.appIsConnected(appName);
            end
        end


        function Close(this,varargin)


            if~isempty(this.Dialog)
                delete(this.Dialog);
                this.Dialog=[];

                wsb=internal.matlab.workspace.peer.PeerWorkspaceBrowserFactory.createWorkspaceBrowser('signal.analyzer.FilteredWorkspace','/SigAnalyzerWSBChannel');
                delete(wsb);

                this.clearSigAppData();
            end
            signal.analyzer.Instance.getSetGUI([]);
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

            if~isempty(signal.analyzer.WebGUI.qeTestingMode())




                return;
            elseif this.UsingSystemBrowser
                if~this.isRunning()
                    this.openGUI();
                end
            elseif isempty(this.Dialog)||~isRunning(this)
                this.openGUI();
            else
                this.Dialog.bringToFront();
            end
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
            sessionInfo=SessionSaveLoad.getSDISessionInfo('appName','siganalyzer');
            this.dirty=Simulink.sdi.sendSessionInfoToClient(...
            'siganalyzer',sessionInfo.Title,...
            sessionInfo.TitleDirty,sessionInfo.FileName);

            title=sessionInfo.Title;
            if this.dirty
                title=sessionInfo.TitleDirty;
            end
            if~this.UsingSystemBrowser&&isRunning(this)&&~isempty(this.Dialog)
                this.Dialog.setTitle(title);
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
                isOpen=signal.analyzer.Instance.isSDIRunning();
                signal.analyzer.Instance.close();
                signal.analyzer.Instance.getSetGUI([]);
                IsDebug=val;
                if isOpen
                    signal.analyzer.Instance.open();
                end
            elseif isempty(IsDebug)
                IsDebug=false;
            end
            isDebug=IsDebug;
        end


        function flag=includeLabeler(val)

            mlock;
            persistent bIncludeLabeler;
            if nargin>0
                isOpen=signal.analyzer.Instance.isSDIRunning();
                signal.analyzer.Instance.close();
                signal.analyzer.Instance.getSetGUI([]);
                bIncludeLabeler=val;
                if isOpen
                    signal.analyzer.Instance.open();
                end
            elseif isempty(bIncludeLabeler)
                bIncludeLabeler=false;
            end
            flag=bIncludeLabeler;
        end


        function flag=haveWaveletToolbox(val)
            mlock;
            persistent bhaveWaveletToolbox;
            if nargin>0
                isOpen=signal.analyzer.Instance.isSDIRunning();
                signal.analyzer.Instance.close();
                signal.analyzer.Instance.getSetGUI([]);
                bhaveWaveletToolbox=val;
                if isOpen
                    signal.analyzer.Instance.open();
                end
            elseif isempty(bhaveWaveletToolbox)
                bhaveWaveletToolbox=false;
            end
            flag=bhaveWaveletToolbox;
        end

        function flag=autoLabeler(val)
            mlock;
            persistent isAutoLabelerOn;
            if nargin>0
                isOpen=signal.analyzer.Instance.isSDIRunning();
                signal.analyzer.Instance.close();
                signal.analyzer.Instance.getSetGUI([]);
                isAutoLabelerOn=val;
                if isOpen
                    signal.analyzer.Instance.open();
                end
            elseif isempty(isAutoLabelerOn)
                isAutoLabelerOn=false;
            end
            flag=isAutoLabelerOn;
        end


        function flag=testAllDomainsMode(val)
            mlock;
            persistent IsTestAllDomainsModeOn;
            if nargin>0
                isOpen=signal.analyzer.Instance.isSDIRunning();
                signal.analyzer.Instance.close();
                signal.analyzer.Instance.getSetGUI([]);
                IsTestAllDomainsModeOn=val;
                if isOpen
                    signal.analyzer.Instance.open();
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
                isOpen=signal.analyzer.Instance.isSDIRunning();
                signal.analyzer.Instance.close();
                signal.analyzer.Instance.getSetGUI([]);
                UsingCEF=val;
                if isOpen
                    signal.analyzer.Instance.open();
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
    end


    methods(Access=protected)


        function initWebGUI(obj,eng,varargin)
            signal.analyzer.startConnector;
            obj.SDIEngine=eng;


            sessionInfo=...
            Simulink.sdi.internal.controllers.SessionSaveLoad.getSDISessionInfo('appName','siganalyzer');
            obj.dirty=Simulink.sdi.cacheSessionInfo('siganalyzer',sessionInfo.Title,sessionInfo.TitleDirty,sessionInfo.FileName,eng.dirty);
            obj.UsingSystemBrowser=Simulink.sdi.getUseSystemBrowser;


            if~isRunning(obj)
                obj.openGUI();
            end
        end


        function openGUI(this)


            import signal.analyzer.WebGUI;
            import matlab.internal.lang.capability.Capability;
            apiObj=signal.analyzer.ConnectorAPI.getAPI();

            if WebGUI.debugMode()
                url=getURL(apiObj,[WebGUI.SA_DEBUG_URL,WebGUI.SIGANALYZER_URL_SUFFIX]);
            else
                url=getURL(apiObj,[WebGUI.SA_REL_URL,WebGUI.SIGANALYZER_URL_SUFFIX]);
            end

            if WebGUI.haveWaveletToolbox()
                url=[url,WebGUI.WAVELETOOLBOX_URL_SUFFIX];
            end
            if WebGUI.autoLabeler()
                url=[url,WebGUI.AUTOLABELER_URL_SUFFIX];
            end
            if WebGUI.testAllDomainsMode()
                url=[url,WebGUI.TESTALLDOMAINS_URL_SUFFIX];
            end

            featureNames=this.FEATURE_CONTROL_NAMES;
            for i=1:numel(featureNames)
                featureName=featureNames{i};
                url=[url,'&',featureName,'=',num2str(matlab.internal.feature(featureName))];%#ok<AGROW> 
            end

            this.ReadyToShowSubscription=message.subscribe(WebGUI.READY_TO_SHOW_CHANNEL,@(e,s)onReadyToShow(this));
            if this.UsingSystemBrowser
                web(connector.applyNonce(url),'-browser');
            else
                title=DAStudio.message('SDI:sigAnalyzer:ToolName');
                useCEF=WebGUI.useCEF();
                debugMode=WebGUI.debugMode();
                testMode=WebGUI.testMode();

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


        function clearSigAppData(this)


            eng=this.SDIEngine;

            runIDs=eng.getAllRunIDs('siganalyzer');
            sigsToDelete=[];
            for idx=1:numel(runIDs)
                runID=runIDs(idx);
                sigs=eng.getAllSignalIDs(runID);
                for kk=1:numel(sigs)
                    sig=sigs(kk);
                    tmMode=eng.getSignalTmMode(sig);
                    if~isempty(tmMode)&&~strcmp(tmMode,'none')
                        sigsToDelete=[sigsToDelete,sig];%#ok<AGROW>
                    end
                end
            end
            if~isempty(sigsToDelete)
                eng.deleteRunsAndSignals(sigsToDelete,'SDI',true);
            end
            sessionSLController=Simulink.sdi.internal.controllers.SessionSaveLoad.getController('siganalyzer');
            sessionSLController.cacheSessionInfo('','',false);
            title=getString(message('SDI:sigAnalyzer:ToolName'));
            Simulink.sdi.cacheSessionInfo('siganalyzer',title,title,'');


            appStateCtrl=signal.analyzer.controllers.AppState.getController();
            if~isempty(appStateCtrl.getSignalAnalyzerClientID())
                matname=signal.sigappsshared.SignalUtilities.getStorageLSSFilename();
                if exist(matname,'file')==2
                    delete(matname)
                end
            end



            appStateCtrl.setSignalAnalyzerClientID([]);
            appStateCtrl.setIsShowVarOverwriteDialog(true);
            appStateCtrl.setSignalAnalyzerActiveAppFlag(true);
            appStateCtrl.setModeName('');

            if~isempty(Simulink.sdi.Instance.getSetSAUtils())
                Simulink.sdi.Instance.getSetSAUtils([]);
            end
        end
    end


    methods(Hidden)

        function onBrowserClose(this)
            signal.analyzer.WebGUI.getSetGeometry(this.Dialog.WindowPosOnClose);
            signal.analyzer.Instance.getSetGUI([]);
            signal.analyzer.Instance.getSetGUIOpenningFlag(false);
        end


        function flag=onBrowserPreClose(this)



            import Simulink.sdi.internal.controllers.SessionSaveLoad;
            appStateCtrl=signal.analyzer.controllers.AppState.getController();
            if appStateCtrl.isPreprocessingModeSA()
                message.publish('/sdi2/displayCloseMsgBoxPreprocessingModeSA',struct);
            else
                SessionSaveLoad.saveSDISessionBeforeClose(this,'appName','siganalyzer');
            end
            flag=false;
        end


        function completeCloseOperation(this)




            this.clearSigAppData();
            this.SDIEngine.publishUpdateLabelsNotification();
            this.Dialog.completeCloseOperation();
        end

        function onReadyToShow(this)
            if isvalid(this)&&~isempty(this.Dialog)
                this.Dialog.show();
            end
            message.unsubscribe(this.ReadyToShowSubscription);
            this.ReadyToShowSubscription=[];
            if~isempty(this.ReadyToShowHandler)&&...
                isa(this.ReadyToShowHandler,'function_handle')
                this.ReadyToShowHandler();
            end
        end
    end


    properties(Access='public',SetObservable)
        dirty=false;
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


    properties(Constant)
        READY_TO_SHOW_CHANNEL='/sdi/readyToShow';
        SA_REL_URL='toolbox/signal/sigappsshared/web/MainView/sa.html';
        SA_DEBUG_URL='toolbox/signal/sigappsshared/web/MainView/sa-debug.html';
        SIGANALYZER_URL_SUFFIX='?sigAnalyzerApp=true';
        AUTOLABELER_URL_SUFFIX='&autoLabeler=true';
        WAVELETOOLBOX_URL_SUFFIX='&waveletToolbox=true';
        TESTALLDOMAINS_URL_SUFFIX='&testAllDomains=true';
        FEATURE_CONTROL_NAMES={
'SignalAnalyzerMeasurementsFindPeaks'
        };
    end
end
