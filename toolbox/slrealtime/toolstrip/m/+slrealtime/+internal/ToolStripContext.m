classdef ToolStripContext<dig.CustomContext







    methods(Access=public)
        function this=ToolStripContext(app,model)
            this=this@dig.CustomContext(app);
            if ischar(model)||isstring(model)
                this.modelHandle=get_param(model,'Handle');
            elseif ishandle(model)
                this.modelHandle=model;
            else
                assert(false,'You must pass a model handle or model name to this constructor.');
            end

            if ismac
                this.disableToolStrip();
                return;
            end

            this.selectedTargetListener=addlistener(this,'selectedTarget','PostSet',@this.createListenersForTarget);











            if isempty(license('inuse','xpc_target'))
                this.doNotInitializeTargets=true;
            else
                this.doNotInitializeTargets=false;
                this.targetEntries=slrealtime.internal.ToolStripContextMgr.getAvailableTargets();
                this.selectedTarget=slrealtime.internal.ToolStripContextMgr.getDefaultTarget();
                this.createListenersForTarget();
            end







            this.TypeChain=[this.TypeChain,{'realTimeCANExplorerNotVisibleContext'}];




            this.TypeChain=[this.TypeChain,{'realTimeCANFDExplorerNotVisibleContext'}];

        end
    end

    methods(Access=public)
        function delete(this)
            this.destroyAllListeners();
        end

        function blockToolStrip(this,message)









            this.blocker=SLStudio.internal.ScopedStudioBlocker(message);
        end
        function unblockToolStrip(this)
            this.blocker=[];
        end

        function disableToolStrip(this)



            this.targetSelectEnabled=false;
            this.connectDisconnectEnabled=false;
            this.connectionStatusEnabled=false;
            this.oneClickRealTimeEnabled=false;
            this.buildRealTimeEnabled=false;
            this.deployRealTimeEnabled=false;
            this.modelConnectRealTimeEnabled=false;
            this.modelDisconnectRealTimeEnabled=false;
            this.startRealTimeEnabled=false;
            this.stopRealTimeEnabled=false;
            this.restartRealTimeEnabled=false;
            this.configureInstrumentRealTimeEnabled=false;
            this.removeInstrumentRealTimeEnabled=false;
            this.highlightInstrumentRealTimeEnabled=false;
            this.importInstrumentRealTimeEnabled=false;
            this.exportInstrumentRealTimeEnabled=false;
            this.recordingControlEnabled=false;
        end

        function refresh(this)
            this.synchToolStripWithSelectedTarget();
        end

        function synchToolStripWithSelectedTarget(this)



            this.blocker=[];

            if~this.targetSelectEnabled




                this.targetSelectEnabled=true;
            end

            if isempty(this.selectedTarget)



                this.connectDisconnectEnabled=false;
                this.connectDisconnectSelected=false;
                this.connectDisconnectIcon='targetComputerDisconnected';

                this.connectionStatusEnabled=false;
                this.connectionStatusText='';

                this.oneClickRealTimeEnabled=false;
                this.buildRealTimeEnabled=false;
                this.deployRealTimeEnabled=false;
                this.modelConnectRealTimeEnabled=false;
                this.modelDisconnectRealTimeEnabled=false;
                this.startRealTimeEnabled=false;
                this.stopRealTimeEnabled=false;
                this.restartRealTimeEnabled=false;
                this.configureInstrumentRealTimeText='slrealtime:toolstrip:RealTimeAddInstrumentText';
                this.configureInstrumentRealTimeIcon='addInstrument';
                this.configureInstrumentRealTimeEnabled=false;
                this.removeInstrumentRealTimeEnabled=false;
                this.highlightInstrumentRealTimeEnabled=false;
                this.importInstrumentRealTimeEnabled=false;
                this.exportInstrumentRealTimeEnabled=false;

                this.recordingControlIcon='stopRecording';
                this.recordingControlText='slrealtime:toolstrip:StopRecordingText';
                this.recordingControlEnabled=false;
                this.recordingControlDescription='slrealtime:toolstrip:StopRecordingDescription';
            else



                this.connectDisconnectEnabled=true;
                this.connectionStatusEnabled=true;


                this.recordingControlEnabled=true;
                tg=slrealtime.internal.ToolStripContext.getSLRTTargetObject(this.selectedTarget);
                if tg.get('Recording')
                    this.recordingControlIcon='stopRecording';
                    this.recordingControlText='slrealtime:toolstrip:StopRecordingText';
                    this.recordingControlDescription='slrealtime:toolstrip:StopRecordingDescription';
                else
                    this.recordingControlIcon='startRecording';
                    this.recordingControlText='slrealtime:toolstrip:StartRecordingText';
                    this.recordingControlDescription='slrealtime:toolstrip:StartRecordingDescription';
                end

                if slrealtime.internal.ToolStripContext.isTargetConnected(this.selectedTarget)



                    this.connectDisconnectSelected=true;
                    this.connectDisconnectIcon='targetComputerConnected';
                    this.connectionStatusText='slrealtime:toolstrip:RealTimeTargetConnectionStatusLabelActionConnectedText';


                    runOnTarget='oneClickRealTimeAction';
                    oneClick=true;
                    build=false;
                    deploy=false;
                    modelConnect=false;
                    modelDisconnect=false;
                    start=false;
                    stop=false;
                    restart=false;

                    if tg.get('BindModeActive')
                        configureInst=false;
                        removeInst=false;
                    else
                        configureInst=true;
                        removeInst=false;
                        if~isempty(tg.get('BindModeInstrument'))
                            removeInst=true;
                        end
                    end

                    if strcmp(get_param(this.modelHandle,'ExtModeConnectButtonEnabled'),'on')
                        if strcmp(get_param(this.modelHandle,'ExtModeConnected'),'on')



                            modelDisconnect=true;
                            oneClick=false;

                            if strcmp(get_param(this.modelHandle,'ExtModeStartButtonEnabled'),'on')
                                if strcmp(get_param(this.modelHandle,'ExtModeTargetSimStatus'),'running')



                                    stop=true;
                                    restart=true;
                                    runOnTarget='stopRealTimeApplicationAction';
                                else



                                    start=true;
                                    runOnTarget='runRealTimeApplicationAction';
                                end
                            end
                        else



                            build=true;

                            tg=slrealtime.internal.ToolStripContext.getSLRTTargetObject(this.selectedTarget);
                            if~tg.isRunning()
                                deploy=true;
                            end
                            if tg.isLoaded(get_param(this.modelHandle,'Name'))
                                modelConnect=true;
                            end





                            if~isempty(this.extmodeParams)&&...
                                strcmp(get_param(this.modelHandle,'ExtModeUploadStatus'),'inactive')



                                dirty=get_param(this.modelHandle,'dirty');




                                for nParam=1:length(this.extmodeParams)
                                    set_param(this.modelHandle,...
                                    this.extmodeParams{nParam}{1},...
                                    this.extmodeParams{nParam}{3});
                                end




                                if strcmp(dirty,'off')
                                    set_param(this.modelHandle,'dirty','off');
                                end

                                this.extmodeParams=[];
                            end

                        end
                    end
                    this.oneClickRealTimeEnabled=oneClick;
                    this.buildRealTimeEnabled=build;
                    this.deployRealTimeEnabled=deploy;
                    this.modelConnectRealTimeEnabled=modelConnect;
                    this.modelDisconnectRealTimeEnabled=modelDisconnect;
                    this.startRealTimeEnabled=start;
                    this.stopRealTimeEnabled=stop;
                    this.restartRealTimeEnabled=restart;
                    this.configureInstrumentRealTimeEnabled=configureInst;
                    this.removeInstrumentRealTimeEnabled=removeInst;
                    this.importInstrumentRealTimeEnabled=configureInst;
                    if removeInst
                        this.configureInstrumentRealTimeText='slrealtime:toolstrip:RealTimeConfigureInstrumentText';
                        this.configureInstrumentRealTimeIcon='configureInstrument';
                        this.highlightInstrumentRealTimeEnabled=true;
                        this.exportInstrumentRealTimeEnabled=true;
                    else
                        this.configureInstrumentRealTimeText='slrealtime:toolstrip:RealTimeAddInstrumentText';
                        this.configureInstrumentRealTimeIcon='addInstrument';
                        this.highlightInstrumentRealTimeEnabled=false;
                        this.exportInstrumentRealTimeEnabled=false;
                    end
                else



                    this.connectDisconnectSelected=false;
                    this.connectDisconnectIcon='targetComputerDisconnected';
                    this.connectionStatusText='slrealtime:toolstrip:RealTimeTargetConnectionStatusLabelActionDisconnectedText';


                    this.oneClickRealTimeEnabled=true;
                    this.buildRealTimeEnabled=true;
                    this.deployRealTimeEnabled=false;
                    this.modelConnectRealTimeEnabled=false;
                    this.modelDisconnectRealTimeEnabled=false;
                    this.startRealTimeEnabled=false;
                    this.stopRealTimeEnabled=false;
                    this.restartRealTimeEnabled=false;
                    this.configureInstrumentRealTimeText='slrealtime:toolstrip:RealTimeAddInstrumentText';
                    this.configureInstrumentRealTimeIcon='addInstrument';
                    this.configureInstrumentRealTimeEnabled=false;
                    this.removeInstrumentRealTimeEnabled=false;
                    this.highlightInstrumentRealTimeEnabled=false;
                    this.importInstrumentRealTimeEnabled=false;
                    this.exportInstrumentRealTimeEnabled=false;
                    this.recordingControlEnabled=true;
                end









                if this.modelConnectRealTimeEnabled||...
                    (~this.modelConnectRealTimeEnabled&&...
                    ~this.modelDisconnectRealTimeEnabled)


                    if~strcmp(this.TypeChain{end},'realTimeExtModeDisconnectedContext')
                        if startsWith(this.TypeChain{end},'realTimeExtMode')

                            this.TypeChain=this.TypeChain(1:end-1);
                        end

                        this.TypeChain=[this.TypeChain,'realTimeExtModeDisconnectedContext'];
                    end
                elseif this.modelDisconnectRealTimeEnabled


                    if this.stopRealTimeEnabled


                        if~strcmp(this.TypeChain{end},'realTimeExtModeRunningContext')
                            if startsWith(this.TypeChain{end},'realTimeExtMode')

                                this.TypeChain=this.TypeChain(1:end-1);
                            end

                            this.TypeChain=[this.TypeChain,'realTimeExtModeRunningContext'];
                        end
                    else


                        if~strcmp(this.TypeChain{end},'realTimeExtModeConnectedContext')
                            if startsWith(this.TypeChain{end},'realTimeExtMode')

                                this.TypeChain=this.TypeChain(1:end-1);
                            end

                            this.TypeChain=[this.TypeChain,'realTimeExtModeConnectedContext'];
                        end
                    end
                end
            end


            if this.displayInstallSPNotification
                this.displayInstallSPNotification=false;
                spkgInstalled=slrealtime.internal.isSpkgInstalled;
                try
                    e=GLUE2.Util.findAllEditors(get_param(this.modelHandle,'Name'));
                    if~spkgInstalled
                        e.deliverInfoNotification('slrealtime:supportpackage:notification',...
                        message('slrealtime:supportpackage:supportPackageRequiredToBuild').getString);
                    else
                        e.closeNotificationByMsgID('slrealtime:supportpackage:notification');
                    end
                catch
                end
            end


            if this.displayUpgradeNotification
                this.displayUpgradeNotification=false;
                stf=get_param(this.modelHandle,'SystemTargetFile');
                try
                    e=GLUE2.Util.findAllEditors(get_param(this.modelHandle,'Name'));
                    if~strcmp(stf,'slrealtime.tlc')
                        e.deliverInfoNotification('slrealtime:advisor:notification',...
                        getString(message('slrealtime:advisor:upgradeBanner',getString(message('slrealtime:advisor:upgradeCheckTitle')))));
                    else
                        e.closeNotificationByMsgID('slrealtime:advisor:notification');
                    end
                catch
                end
            end
        end
    end

    methods(Static)
        function connected=isTargetConnected(targetName)




            connected=false;
            tg=slrealtime.internal.ToolStripContext.getSLRTTargetObject(targetName);
            if~isempty(tg)
                connected=tg.isConnected();
            end
        end

        function tg=getSLRTTargetObject(targetName)




            tg=[];
            try



                tg=slrealtime(targetName);
            catch
            end
        end
    end

    methods(Access=public)



        function destroyAllListeners(this)
            delete(this.selectedTargetListener);
            this.selectedTargetListener=[];
            this.destroyListenersForTarget();
            this.destroyListenersForApplication();
        end

        function destroyListenersForTarget(this)
            if~isempty(this.connectedListener)
                delete(this.connectedListener);
                this.connectedListener=[];
            end
            if~isempty(this.connectCompletedListener)
                delete(this.connectCompletedListener);
                this.connectCompletedListener=[];
            end
            if~isempty(this.disconnectedListener)
                delete(this.disconnectedListener);
                this.disconnectedListener=[];
            end
            if~isempty(this.loadedListener)
                delete(this.loadedListener);
                this.loadedListener=[];
            end
            if~isempty(this.loadCompletedListener)
                delete(this.loadCompletedListener);
                this.loadCompletedListener=[];
            end
            if~isempty(this.unloadedListener)
                delete(this.unloadedListener);
                this.unloadedListener=[];
            end
            if~isempty(this.unloadCompletedListener)
                delete(this.unloadCompletedListener);
                this.unloadCompletedListener=[];
            end
            if~isempty(this.recordingStoppedListener)
                delete(this.recordingStoppedListener);
                this.recordingStoppedListener=[];
            end
            if~isempty(this.recordingStartedListener)
                delete(this.recordingStartedListener);
                this.recordingStartedListener=[];
            end
        end

        function createListenersForTarget(this,varargin)
            this.destroyListenersForTarget();

            tg=slrealtime.internal.ToolStripContext.getSLRTTargetObject(this.selectedTarget);
            if isempty(tg)
                return;
            end

            this.connectedListener=addlistener(tg,'Connected',@this.targetConnectedCB);
            this.connectCompletedListener=[];
            this.disconnectedListener=addlistener(tg,'Disconnected',@this.targetDisconnectedCB);
            this.loadedListener=[];
            this.loadCompletedListener=addlistener(tg,'Loaded',@this.targetLoadedCB);
            this.unloadedListener=addlistener(tg,'LoadFailed',@this.targetUnloadedCB);
            this.unloadCompletedListener=[];

            this.recordingStoppedListener=addlistener(tg,'RecordingStopped',@(src,event)this.recordingStoppedNotificationCB(src,event));
            this.recordingStartedListener=addlistener(tg,'RecordingStarted',@(src,event)this.recordingStartedNotificationCB(src,event));

            this.createListenersForApplication();
        end

        function destroyListenersForApplication(this)
            if~isempty(this.startedListener)
                delete(this.startedListener);
                this.startedListener=[];
            end

            if~isempty(this.stoppedListener)
                delete(this.stoppedListener);
                this.stoppedListener=[];
            end
        end

        function createListenersForApplication(this,varargin)
            this.destroyListenersForApplication();

            tg=slrealtime.internal.ToolStripContext.getSLRTTargetObject(this.selectedTarget);
            if isempty(tg)
                return;
            end





            this.startedListener=addlistener(tg,'Started',@this.targetStartedCB);




            this.stoppedListener=addlistener(tg,'Stopped',@this.targetStoppedCB);
        end

        function closeCallback(this,~)
            this.destroyAllListeners();
        end

        function targetConnectedCB(this,varargin)
            this.createListenersForApplication();
            this.synchToolStripWithSelectedTarget();
        end

        function targetDisconnectedCB(this,varargin)
            this.createListenersForApplication();
            if strcmp(get_param(this.modelHandle,'ExtModeConnected'),'on')
                set_param(this.modelHandle,'SimulationCommand','disconnect');
            end
            this.synchToolStripWithSelectedTarget();
        end

        function targetLoadedCB(this,varargin)
            this.createListenersForApplication();
            this.synchToolStripWithSelectedTarget();
        end

        function targetUnloadedCB(this,varargin)
            this.createListenersForApplication();
            if strcmp(get_param(this.modelHandle,'ExtModeConnected'),'on')
                set_param(this.modelHandle,'SimulationCommand','disconnect');
            end
            this.synchToolStripWithSelectedTarget();
        end

        function targetStartedCB(this,varargin)
            if strcmp(get_param(this.modelHandle,'ExtModeConnected'),'on')
                set_param(this.modelHandle,'SimulationCommand','start');
            end
            this.synchToolStripWithSelectedTarget();
        end

        function targetStoppedCB(this,varargin)
            this.createListenersForApplication();
            if strcmp(get_param(this.modelHandle,'ExtModeConnected'),'on')
                set_param(this.modelHandle,'SimulationCommand','disconnect');
            end
            this.synchToolStripWithSelectedTarget();
        end

        function recordingStoppedNotificationCB(this,obj,evnt)
            tg=slrealtime.internal.ToolStripContext.getSLRTTargetObject(this.selectedTarget);
            if tg~=obj,return;end

            if tg.get('Recording')

                this.recordingStartedNotificationCB(obj,evnt)
            else

                try
                    e=GLUE2.Util.findAllEditors(get_param(this.modelHandle,'Name'));
                    if~any(cellfun(@(x)strcmp(x,'slrealtime:target:notification'),e.getAllNotificationsInQueue()))
                        e.deliverInfoNotification('slrealtime:target:notification',...
                        message('slrealtime:target:recordingStoppedNotification').getString);
                    end
                catch
                end
            end
        end

        function recordingStartedNotificationCB(this,obj,~)
            tg=slrealtime.internal.ToolStripContext.getSLRTTargetObject(this.selectedTarget);
            if tg~=obj,return;end


            try
                e=GLUE2.Util.findAllEditors(get_param(this.modelHandle,'Name'));
                if any(cellfun(@(x)strcmp(x,'slrealtime:target:notification'),e.getAllNotificationsInQueue()))
                    e.closeNotificationByMsgID('slrealtime:target:notification');
                end
            catch
            end
        end
    end

    methods(Access=public)
        function removeConfiguration(~,cs)

            cs.set_param('SystemTargetFile','grt.tlc');
            cs.set_param('HardwareBoard','None');
        end
    end

    methods(Static)





        function isSupported=isDialogSupported()
            isSupported=true;
        end

        function dlg=setupConfigSet(model,cs)
            isSTFChanged=false;
            if~strcmp(cs.get_param('SystemTargetFile'),'slrealtime.tlc')
                cs.set_param('SystemTargetFile','slrealtime.tlc');
                isSTFChanged=true;
            end
            cs.set_param('SolverType','Fixed-step');




            if~isSTFChanged
                dlg=[];
            else
                dlg=slrealtime.internal.ToolStripSetupDlg(model,cs);
            end
        end
    end

    properties
        modelHandle;

        blocker;

selectedTargetListener
connectedListener
connectCompletedListener
disconnectedListener
loadedListener
loadCompletedListener
unloadedListener
unloadCompletedListener
startedListener
stoppedListener

recordingStoppedListener
recordingStartedListener
    end




    properties(SetObservable=true)
        displayInstallSPNotification=true;
        displayUpgradeNotification=true;


        extmodeParams=[];


        doNotInitializeTargets;
        selectedTarget='';
        targetEntries={};
        targetSelectEnabled=true


        connectDisconnectEnabled=true
        connectDisconnectSelected=true
        connectDisconnectIcon='targetComputerDisconnected'


        connectionStatusEnabled=true
        connectionStatusText=''


        oneClickRealTimeEnabled=true
        buildRealTimeEnabled=true
        deployRealTimeEnabled=true
        modelConnectRealTimeEnabled=true
        modelDisconnectRealTimeEnabled=true
        startRealTimeEnabled=true
        stopRealTimeEnabled=true
        restartRealTimeEnabled=true


        configureInstrumentRealTimeText=''
        configureInstrumentRealTimeIcon='addInstrument';
        configureInstrumentRealTimeEnabled=true
        removeInstrumentRealTimeEnabled=true
        highlightInstrumentRealTimeEnabled=true
        importInstrumentRealTimeEnabled=true
        exportInstrumentRealTimeEnabled=true


        autoImportFileLogFlagSelected=true;


        recordingControlIcon='stopRecording'
        recordingControlText='slrealtime:toolstrip:StopRecordingText'
        recordingControlEnabled=false
        recordingControlDescription='slrealtime:toolstrip:StopRecordingDescription'
    end
end
