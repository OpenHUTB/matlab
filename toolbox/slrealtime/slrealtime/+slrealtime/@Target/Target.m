classdef Target<handle









    methods(Access={?slrealtime.Targets})
        function this=Target(TargetSettings)
            validateattributes(TargetSettings,{'slrealtime.TargetSettings'},{'scalar'});
            this.TargetSettings=TargetSettings;
            this.FileLog=slrealtime.internal.logging.FileLogger(this);
            this.Stimulation=slrealtime.internal.StimulationControl(this);
            this.stateChart=TargetStateChart('tg_',this);
        end
    end
    methods(Access=private)
        function delete(this)
            this.disconnectTarget;
        end
    end




    properties(Access=private)
        verbose=false;
    end
    methods(Access=public,Hidden)
        function enableVerbose(this)
            this.verbose=true;
        end
        function disableVerbose(this)
            this.verbose=false;
        end
        function v=isVerbose(this)
            v=this.verbose;
        end
    end




    events
Connecting
ConnectFailed
Connected
PostConnected
Disconnecting
Disconnected
PostDisconnected
Installing
InstallFailed
Installed
Loading
LoadFailed
Loaded
PostLoaded
Starting
StartFailed
Started
PostStarted
Stopping
StopFailed
Stopped
PostStopped
Rebooting
RebootFailed
RebootIssued
UpdateBegin
UpdateMessage
UpdateFailed
UpdateCompleted
SetIPAddressBegin
SetIPAddressFailed
SetIPAddressCompleted
StartupAppChanged
StopTimeChanged
ParamChanged
ParamSetChanged
CalPageChanged
RecordingStarted
RecordingStopped
    end




    methods(Access=public)
        connected=isConnected(this);
        connect(this);
        disconnect(this);
        install(this,app,varargin);
        [loaded,loadedAppName]=isLoaded(this,appName);
        load(this,app,varargin);
        [running,runningAppName]=isRunning(this,appName);
        start(this,varargin);
        stop(this);
        setStopTime(this,stopTime);

        val=getparam(this,blockPath,paramName);
        varargout=setparam(this,blockPath,paramName,val,varargin);

        val=getsignal(this,blockPath,portIndex);

        st=update(this,image,control);

        filename=getApplicationFile(this,appName);
        apps=getInstalledApplications(this);
        removeApplication(this,appName);
        removeAllApplications(this);
    end







    methods(Access=public)
        function savedObj=saveobj(this)
            savedObj.TargetSettings.name=this.TargetSettings.name;
        end
    end
    methods(Access=public,Static)
        function loadedObj=loadobj(obj)
            loadedObj=slrealtime(obj.TargetSettings.name);
        end
    end




    properties(Access=private)
        StartupDirOnTarget='/home/slrt/startup';
        StartupFileName='start-app.sh';
    end
    methods(Access=public)
        setStartupApp(this,app,varargin)
        app=getStartupApp(this)
        clearStartupApp(this)
    end




    methods(Access=private,Static)
        function exc=createExc(errId,varargin)
            msg=message(errId,varargin{:});
            exc=MException(errId,'%s',msg.getString());
        end
        function throwError(errId,varargin)
            throw(slrealtime.Target.createExc(errId,varargin{:}));
        end
        function throwErrorWithCause(errId,cause,varargin)
            exc=slrealtime.Target.createExc(errId,varargin{:});
            throw(exc.addCause(cause));
        end
        function throwErrorAsCaller(errId,varargin)
            throwAsCaller(slrealtime.Target.createExc(errId,varargin{:}));
        end
        function throwErrorAsCallerWithCause(errId,cause,varargin)
            exc=slrealtime.Target.createExc(errId,varargin{:});
            throwAsCaller(exc.addCause(cause));
        end
    end

    methods(Access=public,Static,Hidden)
        function warnIfBusy()
            slrealtime.internal.throw.Warning('slrealtime:target:appLoading');
        end
    end




    methods(Access=public,Static,Hidden)
        info=getSoftwareInfo()
    end

    methods(Access=public,Hidden)
        [status,info,rootssh]=getTargetInfo(this)
    end




    properties(Hidden,Access=private)





sshDoNotUseDirectly
    end
    methods(Access=private)
        rootssh=getRootSSHObj(this)
        res=checkSSHResult(this,ssh)
        res=invokeDefaultSSH(this,method,varargin)
    end
    methods(Hidden,Access=public)
        res=executeCommand(this,command,ssh)
        receiveFile(this,src,dst,ssh)
        sendFile(this,src,dst,ssh)
    end




    properties(Hidden,Constant)
        ModeECUOnly=1;
        ModeXCPOnly=2;
        ModeECUAndXCP=3;


        NumberOfPages=2;



        Segment=0;
    end

    methods(Access=private)
        page=getCalPage(this,mode)
        setCalPage(this,mode,pageNum)
    end

    methods(Access=public)
        val=getNumPages(this)
        pageNum=getECUPage(this)
        pageNum=getXCPPage(this)
        setECUPage(this,pageNum)
        setXCPPage(this,pageNum)
        setECUAndXCPPage(this,pageNum)
        copyPage(this,srcPage,dstPage)
    end




    properties(Access={?slrealtime.internal.xil.MAPort,...
        ?slrealtime.internal.xil.ECUCPort,...
        ?slrealtime.internal.xil.ECUMPort,...
        ?slrealtime.XIL})
        XIL=[]
    end




    properties(Hidden)


        tetSDISigIds=[]


tcTETListener


        tetStreamingToSDI=false




        tetStreamingToSDIDueToTETMonitor=false;
    end
    methods(Access=private)
        addTETToSDI(this)
        tetListenerCB(this,~,~)
    end
    methods(Access={?slrealtime.internal.TETMonitor},Hidden)
        function enableTETStreamingToSDIDueToTETMonitor(this)
            if this.tetStreamingToSDI,return;end

            this.startTET();
            this.tetStreamingToSDIDueToTETMonitor=true;
        end
        function disableTETStreamingToSDIDueToTETMonitor(this)
            if this.tetStreamingToSDIDueToTETMonitor
                this.stopTET();
            end
        end
    end
    methods(Access=private)
        startTET(this)
        stopTET(this)
    end




    methods(Access=private)
        function loadedListenerCB(this,~,~)
            if(this.tc.ModelState==slrealtime.ModelState.LOADED)
                this.stateChart.loaded;
            end
        end

        function loadFailedListenerCB(this,~,~)
            if(this.tc.ModelState==slrealtime.ModelState.INITIALIZE_ERROR)
                this.stateChart.loadFailed;
            end
        end

        function startedListenerCB(this,~,~)
            if(this.tc.ModelState==slrealtime.ModelState.RUNNING)&&...
                (strcmp(this.stateChartGetActiveState(),'Status.Connected.Loaded.NotRunning')||...
                strcmp(this.stateChartGetActiveState(),'Status.Connected.Loaded.Starting'))
                this.stateChart.started;
            end
        end

        function stoppedListenerCB(this,~,~)
            modelStatusDone=(this.tc.ModelConnected==false)&&...
            (this.tc.ModelState==slrealtime.ModelState.DONE||...
            this.tc.ModelState==slrealtime.ModelState.INITIALIZE_ERROR||...
            this.tc.ModelState==slrealtime.ModelState.MODEL_ERROR||...
            this.tc.TargetState==slrealtime.TargetState.TARGET_ERROR);
            if modelStatusDone&&...
                any(startsWith(this.stateChartGetActiveState(),'Status.Connected.Loaded'))
                this.stateChart.stopped;
            end
        end

        function targetConnListenerCB(this,~,~)
            if~this.tc.TargetConnected
                this.stateChart.disconnect;
            end
        end
    end




    methods(Static,Access=private)
        function synchAllToolStrips()
            if~isdeployed&&exist('is_simulink_loaded')&&is_simulink_loaded %#ok
                contexts=coder.internal.toolstrip.HardwareBoardContextManager.getAllContexts();
                for index=1:length(contexts)
                    context=contexts{index};
                    if isa(context,'slrealtime.internal.ToolStripContext')
                        context.synchToolStripWithSelectedTarget();
                    end
                end
            end
        end
    end




    properties(Access=private)
        BindModeActive=false
BindModeDataMap
BindModeInstrument
BindModeModelName
    end
    methods(Hidden,Access=public)
        configureStreaming(this,varargin)
        stopStreaming(this)
        highlightStreaming(this)
        importStreaming(this)
        exportStreaming(this)
    end
    methods(Access=private)
        function processBindModeSignals(this,dataMap)
            this.BindModeActive=false;

            if~isempty(this.BindModeInstrument)
                uuid=this.BindModeInstrument.UUID;
                try
                    this.removeInstrument(this.BindModeInstrument);
                catch
                end
            else
                uuid=[];
            end

            this.BindModeDataMap=dataMap;
            this.BindModeInstrument=slrealtime.Instrument;
            this.BindModeInstrument.RemoveOnStop=false;
            this.BindModeInstrument.MLObsDropIfBusy=false;
            this.BindModeInstrument.StreamingOnly=true;
            if~isempty(uuid)
                this.BindModeInstrument.UUID=uuid;
            end

            if~isempty(dataMap)
                data=dataMap.values;
                for i=1:length(data)
                    blockPath=data{i}.hierarchicalPathArr(2:end);
                    portNumber=data{i}.outputPortNumber;
                    this.BindModeInstrument.addSignal(blockPath,portNumber);
                end

                this.addInstrument(this.BindModeInstrument);
            end

            this.synchAllToolStrips();
        end
    end




    properties(Hidden,Access=private)
        streamingAcquireList=[];
        instrumentList=[];
        mapStreamingALToInstList={};
        streamingAcquireListRefrenceCount=[];
        forceRefresh=false;
    end
    methods(Access=public)
        addInstrument(this,hInst,updateWhileRunning);
        removeInstrument(this,hInst);
        removeAllInstruments(this);
        function hInsts=getAllInstruments(this)
            hInsts=this.instrumentList;
        end
    end
    methods(Access=private)
        mergeInstrument(this,hInst);
        refreshInstrumentList(this,OnStartFlag);
        validateInstrumentList(this);
    end




    properties(Access=private)
        Recording=true
        RecordingOnStart=true;
        StopRecordingBusy=false;
        XCPDisconnectInterrupted=false;











        RemovedInstruments=[]












        CreateSDIRunOnStartRecording=true;

    end
    methods(Access=public)
        stopRecording(this);
        startRecording(this);
    end
    methods(Access=private)
        function cleanupRecording(this)
            this.Recording=this.RecordingOnStart;
            if this.RecordingOnStart
                notify(this,'RecordingStarted');
            else
                notify(this,'RecordingStopped');
            end


            for nInst=1:numel(this.RemovedInstruments)
                this.addInstrument(this.RemovedInstruments(nInst));
            end
            this.RemovedInstruments=[];

            this.synchAllToolStrips();
        end

        function cleanupAsyncFlags(this)
            this.StopRecordingBusy=false;
            this.XCPDisconnectInterrupted=false;
        end
    end























    properties(Access=private)
        LogCANBus=false
CANBusSignals
CANBusInstrument
    end
    methods(Hidden,Access=public)
        function enableCANBusLogging(this)
            if this.LogCANBus
                error('CAN logging has already been enabled');
            end
            if this.isLoaded
                this.setupCANBusLogging();
            end
            this.LogCANBus=true;
        end
        function disableCANBusLogging(this)
            this.LogCANBus=false;
        end
        function value=getCANBusLoggedData(this)
            value=[];

            if isempty(this.CANBusInstrument)||isempty(this.CANBusSignals)
                return;
            end

            inst_data=this.CANBusInstrument.getBufferedData();
            if isempty(inst_data),return;end

            value=struct('time',{},'data',{});
            try
                for nSig=1:numel(this.CANBusSignals)
                    signal=slrealtime.internal.instrument.Util.checkAndFormatSignalArgs(this.CANBusSignals(nSig).BlockPath,this.CANBusSignals(nSig).PortIndex);
                    value(nSig)=inst_data(this.CANBusInstrument.getSignalStringForMap(signal,1,[],[]));
                end
            catch
                value=[];
            end
        end
    end
    methods(Access=private)
        function setupCANBusLogging(this)
            appName=this.tc.ModelProperties.Application;
            this.CANBusInstrument=slrealtime.Instrument(this.getAppFile(appName));
            this.CANBusInstrument.RemoveOnStop=true;
            this.CANBusInstrument.BufferData=true;
            [CANSignals,CANFDSignals]=this.slrtApp.getCANSignals();

            if isempty(CANSignals)&&isempty(CANFDSignals)

                return;
            elseif~isempty(CANSignals)&&~isempty(CANFDSignals)

                error('Cannot log CAN and CAN FD signals simulatneously');
            elseif~isempty(CANSignals)

                this.CANBusSignals=CANSignals;
            else

                this.CANBusSignals=CANFDSignals;
            end

            arrayfun(@(x)this.CANBusInstrument.addSignal(x.BlockPath,x.PortIndex),this.CANBusSignals);
            this.addInstrument(this.CANBusInstrument);
        end
        function cleanupCANBusLogging(this)
            this.CANBusSignals=[];
            this.CANBusInstrument=[];
        end
    end





    methods(Access=public)
        vars=getPersistentVariables(this);
        setPersistentVariables(this,vars);
    end




    methods(Hidden)
        xcpConnect(this);
        xcpDisconnect(this);
        xcpStartMeasurement(this,varargin);
        function val=stateChartGetActiveState(this)
            val=this.stateChart.getActiveStates{end};
        end

        function acquireList=getStreamingsAcquireList(this)
            acquireList=this.streamingAcquireList;
        end

        chkok=checkFile(this,localfn,remotefn,checksumdir,ssh)
        [imageok,qnxok,slrtok,sgok]=checkVersion(this)

        disconnectTarget(this)

        postLoad(this)
        postStart(this)
        postStop(this)

        filename=getVerifyDataFile(this,appName)
    end
    methods(Access=private)
        xcpExtractFromApp(this,appName)
        ps=getProfilerStatus(this)
        killProcess(this,procName)
    end




    properties(SetAccess=private)
TargetSettings
ProfilerStatus
SDIRunId
ptpd
    end

    properties(Hidden,SetAccess=private)
xcp
    end

    properties(Hidden,Access=private)
slrtApp
mldatxCodeDescFolder
mldatxMiscFolder
tc
uploadedMLDATXFolder
tcLoadedListener
tcLoadFailedListener
tcStartedListener
tcStoppedListener
tcTargetConnListener
stateChart
ReloadOnStop_StopTime
    end

    properties(Hidden,Access=private)
        RunProfiler=false;
    end
    properties(SetAccess=private,GetAccess=public)
FileLog
Stimulation
    end

    properties(Dependent)
        TargetStatus;
        ModelStatus;
    end




    methods

        function ps=get.ProfilerStatus(this)
            if~this.isConnected()
                ps=[];
                return;
            end
            ps=getProfilerStatus(this);
        end

        function targetStatus=get.TargetStatus(this)
            targetStatus=[];
            if isempty(this.tc)||~this.tc.TargetConnected
                return;
            end
            targetStatus=struct;
            targetStatus.State=this.tc.TargetState;
            targetStatus.Error=this.tc.TargetProperties.Error;
        end

        function modelStatus=get.ModelStatus(this)
            modelStatus=[];
            if isempty(this.tc)||~this.tc.TargetConnected
                return;
            end
            modelStatus=struct;
            modelStatus.State=this.tc.ModelState;
            modelStatus.Application=this.tc.ModelProperties.Application;
            modelStatus.ModelName=this.tc.ModelProperties.ModelName;
            modelStatus.Error=this.tc.ModelProperties.ErrorDesc;
            modelStatus.LogLevel=this.tc.ModelProperties.LogLevel;
            modelStatus.PollingThreshold=this.tc.ModelProperties.PollingThreshold;
            modelStatus.FileLogMaxRuns=this.tc.ModelProperties.FileLogMaxRuns;
            modelStatus.OverrideBaseRatePeriod=this.tc.ModelProperties.OverrideBaseRatePeriod;
            modelStatus.StopTime=this.tc.ModelProperties.StopTime;
            modelStatus.ExecTime=this.tc.ModelExecProperties.ExecTime;
            modelStatus.TETInfo=this.tc.ModelExecProperties.TETInfo;
        end
    end




    properties(Hidden,SetAccess=private,GetAccess=public)
        HomeDir;
    end




    methods(Hidden,Access=public)
        deletefolder(this,folder);
        deletefile(this,fileName);
        res=isfile(this,fileName);
        res=isfolder(this,dirName);
        copyfolder(this,src,dest);
        cleanfolder(this,dirName);
        res=getfilesize(this,fileName);
    end

    methods(Hidden,Access=public)
        uuid=getUUIDFromTarget(this,appName);

        function val=appsDirOnTarget(this)
            val=strcat(this.HomeDir,'/applications');
        end

        filename=getAppFile(this,appName);

        dataAvailableFromObserver(this,cbg,varargin)

        corefiles=getCoreFiles(this,varargin);

        resetLogs(this);
    end

    properties(Access=private)
        StopProperties=slrealtime.internal.TargetStopProperties
    end

    methods(Hidden)


        out=get(this,prop);
        set(this,prop,val);
    end

    properties(Hidden)
        UseActiveFTP(1,1)logical=false
    end
end
