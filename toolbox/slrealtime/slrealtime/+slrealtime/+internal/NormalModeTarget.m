classdef NormalModeTarget<handle



    properties(Access=private)
tc
tcTimer
        connected=false
    end

    properties(Access=public)
ModelName
ModelStatus
TargetSettings
    end

    properties(Access=public,Hidden)
Instruments
Mapping
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







    methods(Access=private)
        function obj=NormalModeTarget()
            obj.ModelStatus.State='';
            obj.ModelStatus.Application='';
            obj.ModelStatus.ExecTime=0;
            obj.TargetSettings.name=slrealtime.ui.control.TargetSelector.SIMULINK_NORMAL_MODE;
        end
    end
    methods(Access=public,Static,Hidden)
        function resetInstance()
            slrealtime.internal.NormalModeTarget.setInstance([]);
        end
    end
    methods(Access=public,Static)
        function obj=getInstance()
            obj=slrealtime.internal.NormalModeTarget.manageInstance('get');
            if isempty(obj)
                obj=slrealtime.internal.NormalModeTarget;
                slrealtime.internal.NormalModeTarget.setInstance(obj);
            end
        end
    end
    methods(Access=private,Static)
        function setInstance(obj)
            slrealtime.internal.NormalModeTarget.manageInstance('set',obj);
        end
        function varargout=manageInstance(command,varargin)
            mlock;
            persistent theInstance;
            switch(command)
            case 'get'
                varargout{1}=theInstance;
            case 'set'
                theInstance=varargin{1};
            otherwise
                assert(false);
            end
        end
    end




    methods(Access=private)
        function val=isModelSimulationStopped(this)
            val=true;

            if isempty(this.ModelName),return;end

            try
                val=strcmp(get_param(this.ModelName,'SimulationStatus'),'stopped');
            catch
            end
        end

        function val=getModelStopTime(this)
            val=str2double(get_param(this.ModelName,'StopTime'));
        end

        function setModelStopTime(this,stopTime)
            set_param(this.ModelName,'StopTime',num2str(stopTime));
        end

        function startModelSimulation(this)
            set_param(this.ModelName,'SimulationMode','normal');
            set_param(this.ModelName,'SimulationCommand','start');
        end

        function stopModelSimulation(this)
            set_param(this.ModelName,'SimulationCommand','stop');
        end

        function clearModelStreamingClients(this)
            clients=Simulink.HMI.StreamingClients(this.ModelName);
            set_param(this.ModelName,'StreamingClients',clients);
        end
    end




    methods(Access=public,Hidden)
        function out=get(this,prop)
            out=this.(prop);
        end

        function dataAvailableFromObserver(this,cbg,varargin)
            try
                nInsts=length(this.Instruments);
                acquireSignalDatas=cell(nInsts,1);
                for nInst=1:nInsts
                    if this.Instruments(nInst).AcquireList.AcquireListModel.nAcquireGroups==0
                        asd=[];
                    else
                        asd(this.Instruments(nInst).AcquireList.AcquireListModel.nAcquireGroups,this.Instruments(nInst).AcquireList.AcquireListModel.MaxGroupLength)=struct('Time',[],'Data',[]);%#ok
                    end
                    acquireSignalDatas{nInst}=asd;
                    clear asd
                end

                if isempty(this.Mapping)
                    return;
                end

                for icbg=1:length(cbg)
                    global_agi=double(cbg(icbg).groupNum);
                    global_si=str2double(cbg(icbg).cbParam);

                    vec_local_inst=this.Mapping{global_agi,global_si}(:,1);
                    vec_local_agi=this.Mapping{global_agi,global_si}(:,2);
                    vec_local_si=this.Mapping{global_agi,global_si}(:,3);

                    for nSig=1:length(vec_local_inst)
                        local_inst=vec_local_inst(nSig);
                        local_agi=vec_local_agi(nSig);
                        local_si=vec_local_si(nSig);

                        if isempty(acquireSignalDatas{local_inst}(local_agi,local_si).Time)

                            acquireSignalDatas{local_inst}(local_agi,local_si).Time=cbg(icbg).time;
                            acquireSignalDatas{local_inst}(local_agi,local_si).Data=cbg(icbg).data;
                        else

                            acquireSignalDatas{local_inst}(local_agi,local_si).Time=[acquireSignalDatas{local_inst}(local_agi,local_si).Time;cbg(icbg).time];
                            acquireSignalDatas{local_inst}(local_agi,local_si).Data=[acquireSignalDatas{local_inst}(local_agi,local_si).Data;cbg(icbg).data];
                        end
                    end
                end


                for nInst=1:nInsts
                    this.Instruments(nInst).dataAvailableFromObserverViaTarget(acquireSignalDatas{nInst});
                end
            catch ME
                if~strcmp(ME.identifier,'MATLAB:badsubscript')&&...
                    ~strcmp(ME.identifier,'MATLAB:structRefFromNonStruct')&&...
                    ~strcmp(ME.identifier,'MATLAB:cellRefFromNonCell')






                    rethrow(ME);
                end
            end
        end
    end
    methods(Access=private)
        function timerCallback(this)
            this.tc.ModelExecProperties.ExecTime=get_param(this.ModelName,'SimulationTime');
            if this.isModelSimulationStopped()
                this.modelStopped();
            end
            try
                drawnow limitrate;
            catch
            end
        end

        function setupMLCbObs(this,blockPath,portIndex,obsParams)


            ph=get_param(blockPath,'PortHandles');

            set_param(ph.Outport(portIndex),'DataLogging','on');

            mdl=this.ModelName;


            strClients=get_param(mdl,'StreamingClients');
            if~isempty(strClients)




                for index=1:strClients.Count
                    sc=strClients.get(index);

                    if sc.SignalInfo.BlockPath.isequal(blockPath)&&...
                        isequal(sc.SignalInfo.OutputPortIndex,portIndex)&&...
                        strcmp(sc.ObserverType,'matlab_observer')
                        slrealtime.internal.throw.Warning('slrealtime:appdesigner:NormalModeNoStreaming');
                        return;
                    end
                end
            end


            strClients=get_param(mdl,'StreamingClients');
            if isempty(strClients)
                strClients=Simulink.HMI.StreamingClients;
            end

            is=get_param(mdl,'InstrumentedSignals');

            for index=1:is.Count
                ss=is.get(index);

                if ss.BlockPath.isequal(blockPath)&&...
                    isequal(ss.OutputPortIndex,portIndex)


                    sigClient=Simulink.HMI.SignalClient;
                    sigClient.SignalInfo=ss;
                    sigClient.ObserverType='matlab_observer';
                    sigClient.ObserverParams=obsParams;


                    strClients.add(sigClient);


                    set_param(mdl,'StreamingClients',strClients);
                else
                    continue;
                end
            end
        end
    end




    methods(Access=public)
        function update(this)%#ok
        end
    end




    methods(Access=public)
        function connect(this)
            if this.isConnected(),return;end

            notify(this,'Connecting');

            try
                if isempty(this.tc)
                    this.tc=slrealtime.internal.NormalModeTargetControl;
                    this.tc.ModelProperties.Application='';
                end

                pause(2);
            catch ME
                notify(this,'ConnectFailed');
                slrealtime.internal.throw.Error('slrealtime:target:connectError',...
                this.TargetSettings.name,ME.message);
            end

            this.connected=true;

            notify(this,'Connected');
            notify(this,'PostConnected');
        end

        function disconnect(this)
            if~this.isConnected(),return;end

            notify(this,'Disconnecting');

            pause(0.5);

            this.connected=false;

            this.ModelStatus.State=[];
            this.ModelStatus.Application='';
            this.ModelStatus.ExecTime=0;
            this.ModelName='';
            this.tc=[];

            notify(this,'Disconnected');
            notify(this,'PostDisconnected');
        end

        function val=isConnected(this)
            val=this.connected;
        end
    end




    methods(Access=public)
        function load(this,modelName,varargin)
            if~this.isConnected()
                this.connect;
            end

            notify(this,'Loading');

            try
                if~this.isModelSimulationStopped()
                    slrealtime.internal.throw.Error('slrealtime:appdesigner:NormalModeLoadModelRunning');
                end

                open_system(modelName);
                this.ModelName=modelName;
                this.ModelStatus.StopTime=this.getModelStopTime();
                this.ModelStatus.State='LOADED';
                this.ModelStatus.Application=modelName;
                this.tc.ModelState='LOADED';
                this.tc.ModelProperties.Application=modelName;
            catch ME
                notify(this,'LoadFailed');
                slrealtime.internal.throw.Error('slrealtime:target:loadError',...
                modelName,this.TargetSettings.name,ME.message);
            end

            notify(this,'Loaded');
            notify(this,'PostLoaded');
        end

        function[loaded,loadedAppName]=isLoaded(this,appName)
            if nargin<2
                appName=[];
            end

            if isempty(appName)
                loaded=~isempty(this.ModelName);
                loadedAppName=this.ModelName;
            else
                loaded=strcmp(this.ModelName,appName);
                loadedAppName=appName;
            end
        end
    end




    methods(Access=public)
        function setStopTime(this,stopTime)
            this.setModelStopTime(stopTime);
            this.ModelStatus.StopTime=stopTime;
        end
    end




    methods(Access=public)
        function val=getparam(this,blockPath,paramName)
            try
                if isempty(blockPath)
                    val=slResolve(paramName,this.ModelName);
                else
                    if iscell(blockPath)&&length(blockPath)>1
                        params=get_param(blockPath{1},'InstanceParameters');
                        if isempty(params)
                            slrealtime.internal.throw.Error('slrealtime:appdesigner:NormalModeNoInstanceParam');
                        end

                        bp=Simulink.BlockPath(blockPath(2:end));
                        idxs=find(cellfun(@(x)isequal(x,bp),{params.Path}));
                        if isempty(idxs)
                            slrealtime.internal.throw.Error('slrealtime:appdesigner:NormalModeNoInstanceParam');
                        end

                        val=params(idxs(1)).Value;
                    else
                        val=get_param(blockPath,paramName);
                    end
                end
            catch ME
                slrealtime.internal.throw.Error('slrealtime:target:getparamError',...
                paramName,this.TargetSettings.name,ME.message);
            end
        end

        function setparam(this,blockPath,paramName,val)
            try
                if isempty(blockPath)
                    try
                        res=evalin('base',paramName);%#ok
                        evalin('base',[paramName,' = ',mat2str(val),';']);
                    catch
                        mdl_wks=get_param(this.ModelName,'ModelWorkspace');
                        if mdl_wks.hasVariable(paramName)
                            var=mdl_wks.getVariable(paramName);
                            var.Value=val;
                        else
                            slrealtime.internal.throw.Error('slrealtime:appdesigner:NormalModeNoWorkspaceVar');
                        end
                    end
                    if~this.isModelSimulationStopped()
                        set_param(this.ModelName,'SimulationCommand','update');
                    end
                else
                    if iscell(blockPath)&&length(blockPath)>1
                        params=get_param(blockPath{1},'InstanceParameters');
                        if isempty(params)
                            slrealtime.internal.throw.Error('slrealtime:appdesigner:NormalModeNoInstanceParam');
                        end

                        bp=Simulink.BlockPath(blockPath(2:end));
                        idxs=find(cellfun(@(x)isequal(x,bp),{params.Path}));
                        if isempty(idxs)
                            slrealtime.internal.throw.Error('slrealtime:appdesigner:NormalModeNoInstanceParam');
                        end

                        params(idxs(1)).Value=val;
                        set_param(blockPath{1},'InstanceParameters',params);
                    else
                        set_param(blockPath,paramName,val);
                    end
                end

                notify(this,'ParamChanged',...
                slrealtime.events.TargetParamData(blockPath,paramName,val));
            catch ME
                slrealtime.internal.throw.Error('slrealtime:target:setparamError',...
                paramName,this.TargetSettings.name,ME.message);
            end
        end
    end




    methods(Access=public)
        function addInstrument(this,instrument)
            if~isempty(instrument.LockedByTarget)


                slrealtime.internal.throw.Error('slrealtime:target:addInstAlreadyLocked',...
                this.TargetSettings.name,instrument.LockedByTarget.TargetSettings.name);
            end
            instrument.LockedByTarget=this;

            if~this.isModelSimulationStopped()
                slrealtime.internal.throw.Error('slrealtime:appdesigner:NormalModeAddInstModelRunning');
            end

            if isempty(this.Instruments)
                this.Instruments=instrument;
            else
                this.Instruments(end+1)=instrument;
            end
        end

        function removeInstrument(this,instrument)
            if isempty(instrument)||~any(this.Instruments==instrument)
                slrealtime.internal.throw.Error('slrealtime:target:removeInstInvalidArg',...
                this.TargetSettings.name);
            end

            instrument.LockedByTarget=[];
            instrument.validate([]);
            this.Instruments(this.Instruments==instrument)=[];
        end

        function removeAllInstruments(this)
            arrayfun(@(x)this.removeInstrument(x),this.Instruments);
            this.Instruments=[];
        end

        function hInsts=getAllInstruments(this)
            hInsts=this.Instruments;
        end
    end




    methods(Access=public)
        function start(this,varargin)
            if~this.isConnected()
                this.connect;
            end

            notify(this,'Starting');

            S=warning('off','Simulink:LoadSave:UnsupportedDataFormat');
            c=onCleanup(@()warning(S));

            try
                if~this.isModelSimulationStopped()
                    slrealtime.internal.throw.Error('slrealtime:appdesigner:NormalModeStartModelRunning');
                end

                application=['MODEL:',this.ModelName];
                acquireList=slrealtime.internal.instrument.AcquireList(application);



                feval(this.ModelName,[],[],[],'compile');
                c=onCleanup(@()feval(this.ModelName,[],[],[],'term'));
                for nInst=1:length(this.Instruments)
                    this.Instruments(nInst).validate(application);
                end
                delete(c);
                clear c;

                for nInst=1:length(this.Instruments)
                    this.Instruments(nInst).registerObserversWithTarget(this);
                    ALM=this.Instruments(nInst).AcquireList.AcquireListModel;

                    for agi=1:ALM.nAcquireGroups
                        for si=1:double(ALM.AcquireGroups(agi).xcpSignals.Size())
                            xcpsig=ALM.AcquireGroups(agi).xcpSignals(si);
                            if xcpsig.attachMatlabObs



                                signalStructs=getAcquireXcpSignal(this.Instruments(nInst).AcquireList.AcquireListModel,agi);
                                signal=struct(...
                                'blockpath',signalStructs(si).SimulationDataBlockPath,...
                                'portindex',signalStructs(si).portNumber+1,...
                                'signame','',...
                                'statename','',...
                                'decimation',this.Instruments(nInst).AcquireList.AcquireListModel.AcquireGroups(agi).decimation);

                                output=getAcquireSignalIndex(acquireList.AcquireListModel,signal);
                                if output.signalindex==-1


                                    signalStruct=this.Instruments(nInst).AcquireList.AcquireListModel.AcquireGroups(agi).signalStructs(si);
                                    output=acquireList.AcquireListModel.addSignalFromXcpSignalInfo(signalStruct,xcpsig,signal.decimation);
                                    globagi=output.acquiregroupindex;
                                    globsi=output.signalindex;


                                    blockpath=xcpsig.SimulationDataBlockPath.convertToCell{1};
                                    portindex=xcpsig.portNumber;
                                    obsParams.Enable=true;
                                    obsParams.IncludeTime=true;
                                    obsParams.Function=xcpsig.matlabObsFcn;
                                    obsParams.ModelName=this.ModelName;
                                    obsParams.Param=num2str(globsi);
                                    obsParams.CallbackGroup=uint32(globagi);
                                    obsParams.FuncHandle=xcpsig.matlabObsFuncHandle;
                                    this.setupMLCbObs(blockpath,portindex+1,obsParams);

                                    this.Mapping{globagi,globsi}=[nInst,agi,si];
                                else


                                    globagi=output.acquiregroupindex;
                                    globsi=output.signalindex;

                                    this.Mapping{globagi,globsi}=[this.Mapping{globagi,globsi};[nInst,agi,si]];
                                end
                            end
                        end
                    end
                end

                this.startModelSimulation();
                pause(1);
            catch ME
                notify(this,'StartFailed');
                slrealtime.internal.throw.Error('slrealtime:target:startError',this.TargetSettings.name,ME.message);
            end

            notify(this,'Started');
            notify(this,'PostStarted');

            this.tc.ModelState='RUNNING';
            this.ModelStatus.State='RUNNING';
            this.tcTimer=timer('ExecutionMode','fixedRate','Period',0.1,'TimerFcn',@(o,e)this.timerCallback);
            this.tcTimer.start;
        end

        function stop(this)
            try
                this.stopModelSimulation();
                pause(1);
            catch

            end
        end

        function[running,runningAppName]=isRunning(this,appName)
            if nargin<2
                appName=[];
            end

            if~this.isLoaded()
                running=false;
                runningAppName=[];
            else
                if isempty(appName)
                    running=~this.isModelSimulationStopped();
                    runningAppName=this.ModelName;
                else
                    if~strcmp(this.ModelName,appName)
                        running=false;
                        runningAppName=[];
                    else
                        running=~this.isModelSimulationStopped();
                        runningAppName=this.ModelName;
                    end
                end
            end
        end
    end
    methods(Access=private)
        function modelStopped(this)
            try
                this.clearModelStreamingClients();
            catch

            end

            for nInst=1:length(this.Instruments)
                if this.Instruments(nInst).RemoveOnStop
                    this.removeInstrument(this.Instruments(nInst));
                end
            end


            for nInst=1:length(this.Instruments)
                this.Instruments(nInst).validate([]);
            end

            this.Mapping=[];

            notify(this,'Stopped');
            notify(this,'PostStopped');



            this.tc.ModelState='LOADED';
            this.ModelStatus.State='LOADED';

            if~isempty(this.tcTimer)
                this.tcTimer.stop;
                delete(this.tcTimer);
                this.tcTimer=[];
            end
        end
    end
end
