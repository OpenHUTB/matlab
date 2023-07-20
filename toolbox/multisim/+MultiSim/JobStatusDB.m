classdef JobStatusDB<handle




    properties(Constant)
        JobStatusDBConfig=MultiSim.internal.JobStatusDBConfig
    end

    properties(SetAccess=private,GetAccess=public)
ModelName
Status
SimMetadata
NumWorkers
NumSims
ETA
StartTime
StopTime
        IsRunning(1,1)logical
LastSavedElapsedTime

HeaderDataChannel
RunDetailsChannel
RunStatusChannel

NotifyAppChannel
    end

    properties
FinalStatusReceived
    end

    properties(Access=private)
StatusUpdateThrottler
ProgressUpdateThrottler
RunIdNeedsPublish
NumUpdatesToPublish
SimElapsedRefreshRate
    end

    properties(Access=private,Transient=true)
Listeners
    end

    properties(SetAccess=private,GetAccess=public,Transient=true)
RunSubscriptionSub
SlssConnectionId
SlssListener
    end

    properties(Constant)
        DefaultStatus=struct('RunId',-1,...
        'StatusString',message('Simulink:MultiSim:Queued').getString(),...
        'Progress',0,...
        'SimStatus','',...
        'Status',message('Simulink:MultiSim:Queued').getString(),...
        'SimElapsedWallTime',0,...
        'SimElapsedWallTimeNumeric',0,...
        'ETA',0,...
        'Aborted',false,...
        'Machine',message('Simulink:MultiSim:Pending').getString(),...
        'Subscribed',1);
        ProgressUpdateThreshold=5
    end

    properties(Constant)
        ActiveMsg=message('Simulink:MultiSim:Active').getString()
        CompletedMsg=message('Simulink:MultiSim:Completed').getString()
        CompletedWithWarningsMsg=message('Simulink:MultiSim:CompletedWithWarnings').getString()
        ErrorsMsg=message('Simulink:MultiSim:Errors').getString()
        AbortedMsg=message('Simulink:MultiSim:Aborted').getString()
        PendingMsg=message('Simulink:MultiSim:Pending').getString()
        SimAndCallbacksCompletedMsg='SimAndCallbacksCompleted'
    end

    events
DBChanged
SimulationCompleted
RunStatusUpdated
    end

    methods
        function obj=JobStatusDB(job,simMgr)
            addlistener(job,'SimulationManager','PostSet',@obj.handleSimManagerChange);
            obj.ModelName=simMgr.ModelName;
            obj.createDB(simMgr);

            obj.setupConnector(job);

            obj.SlssConnectionId=uint32.empty;
            obj.SlssListener=[];

            obj.addListeners(simMgr);

            statusUpdateThrottleRate=0.05;
            obj.StatusUpdateThrottler=obj.JobStatusDBConfig.FunctionCallThrottler(...
            @obj.finishPendingUpdates,statusUpdateThrottleRate);

            progressUpdateThrottleRate=1.0;
            obj.ProgressUpdateThrottler=obj.JobStatusDBConfig.FunctionCallThrottler(...
            @(runId,newProgress)obj.updateRun(runId,'Progress',newProgress),progressUpdateThrottleRate);
        end

        function set.IsRunning(obj,val)
            obj.IsRunning=val;
            dig.postStringEvent('SimulinkEvent:Simulation');
        end

        function attachToJob(obj,job)
            addlistener(job,'SimulationManager','PostSet',@obj.handleSimManagerChange);
        end

        function ReceiveUpdatesCB(obj,msg)





            if~isvalid(obj)
                return;
            end

            try

                if(~isempty(obj.FinalStatusReceived)&&...
                    (obj.FinalStatusReceived(msg.RunId)||...
                    all(obj.FinalStatusReceived)))
                    return
                end

                if isfield(msg,'SimElapsedWallTime')

                    elapsedTime=msg.SimElapsedWallTime;
                    if(abs(elapsedTime-obj.LastSavedElapsedTime(msg.RunId))>obj.SimElapsedRefreshRate)
                        obj.LastSavedElapsedTime(msg.RunId)=elapsedTime;
                        obj.updateRun(msg.RunId,'SimElapsedWallTime',elapsedTime);
                    end
                    obj.Status(msg.RunId).SimElapsedWallTime=elapsedTime;
                elseif isfield(msg,'StatusString')
                    obj.updateRun(msg.RunId,'StatusString',msg.StatusString);
                elseif isfield(msg,'Progress')
                    newProgress=min(100,fix(msg.Progress));



                    forceProgressUpdate=(abs(newProgress-obj.Status(msg.RunId).Progress)>=obj.ProgressUpdateThreshold||...
                    newProgress==100||newProgress==0);
                    obj.ProgressUpdateThrottler.call({msg.RunId,newProgress},'Force',forceProgressUpdate);
                elseif isfield(msg,'SimStatus')
                    simStatus=msg.SimStatus;
                    obj.updateRun(msg.RunId,'SimStatus',simStatus);
                elseif isfield(msg,'Machine')
                    obj.updateRun(msg.RunId,'Machine',msg.Machine);
                end
            catch ME
                if isvalid(obj)
                    rethrow(ME);
                end
            end
        end

        function delete(obj)
            delete(obj.Listeners);
            if~isempty(obj.SlssConnectionId)
                mgr=slss.Manager;
                mgr.disconnect(obj.SlssConnectionId);
                obj.SlssConnectionId=uint32.empty;
            end
            message.unsubscribe(obj.RunSubscriptionSub);
        end

        function setNumWorkers(obj,numWorkers)
            obj.NumWorkers=numWorkers;
            obj.publishHeader;
        end

        function publishHeader(obj)
            outMsg=struct;
            outMsg.numWorkers=obj.NumWorkers;
            outMsg.numSims=obj.NumSims;
            if~isempty(obj.StopTime)
                outMsg.time=etime(datevec(obj.StopTime),datevec(obj.StartTime));
            else
                outMsg.time=etime(datevec(now),datevec(obj.StartTime));
            end
            outMsg.isRunning=obj.IsRunning;
            message.publish(obj.HeaderDataChannel,outMsg);
        end

        function updateHeader(obj)
            if isempty(obj.IsRunning)
                return;
            end

            needsUpdate=false;

            if obj.IsRunning
                startTimer=true;
                elapsedTime=etime(datevec(now),datevec(obj.StartTime));
                needsUpdate=true;
            else
                if~isempty(obj.StopTime)
                    startTimer=false;
                    elapsedTime=etime(datevec(obj.StopTime),datevec(obj.StartTime));
                    needsUpdate=true;
                end
            end

            if needsUpdate
                outMsg=struct('NumWorkers',obj.NumWorkers,...
                'NumSims',obj.NumSims,...
                'Time',elapsedTime,...
                'IsRunning',obj.IsRunning,...
                'StartTimer',startTimer);

                message.publish(obj.HeaderDataChannel,outMsg);
            end
        end

        function setExecutionStatus(obj,running)
            publishRequired=true;
            if running
                obj.StartTime=now;
                obj.StopTime=[];
            else
                if obj.IsRunning


                    obj.StopTime=now;
                    if~isempty(obj.SlssListener)
                        mgr=slss.Manager;
                        delete(obj.SlssListener);
                        obj.SlssListener=[];
                    end
                else


                    publishRequired=false;
                end
            end
            obj.IsRunning=running;

            if publishRequired
                outMsg=struct;
                outMsg.NumWorkers=obj.NumWorkers;
                outMsg.NumSims=obj.NumSims;
                if~isempty(obj.StopTime)
                    outMsg.Time=etime(datevec(obj.StopTime),datevec(obj.StartTime));
                else
                    outMsg.Time=etime(datevec(now),datevec(obj.StartTime));
                end
                outMsg.IsRunning=running;

                message.publish(obj.HeaderDataChannel,outMsg);
            end
        end

        function runSubscriptionHandler(obj,msg)


            if~obj.IsRunning
                return;
            end
            startId=msg.startRunId;
            endId=msg.endRunId;
            status=obj.Status;
            for i=startId:endId




                if msg.subscribed>0&&...
                    strcmp(status.Status,obj.ActiveMsg)
                    obj.publishStatus(i);
                end
                status(i).Subscribed=status(i).Subscribed+msg.subscribed;
            end
            obj.Status=status;
        end

        function handleAbortSimulations(obj,eventData)


            obj.FinalStatusReceived(eventData.RunIds)=true;
        end

        function handleSimulationAborted(obj,runIds,md)
            abortedStr=message('Simulink:MultiSim:Aborted').getString();
            abortedStatus=struct('StatusString',abortedStr,...
            'Status',abortedStr,...
            'Progress',100,...
            'ExecutionInfo',md.ExecutionInfo);



            message.publish(obj.NotifyAppChannel,struct('Event','JobAborted',...
            'RunIds',runIds,'Status',abortedStatus));

            for i=1:length(runIds)
                runId=runIds(i);
                obj.Status(runId).StatusString=abortedStr;
                obj.Status(runId).Status=abortedStr;
                obj.Status(runId).Progress=100;
                obj.SimMetadata(runId).ExecutionInfo=md.ExecutionInfo;
                obj.Status(runId).Aborted=true;
            end
        end

        function updateRun(obj,runId,varargin)
            currentStatus=obj.Status(runId);

            if currentStatus.Aborted
                return;
            end

            changed=false;
            changedStatus=false;
            for i=1:2:(nargin-3)
                field=varargin{i};
                value=varargin{i+1};

                if isempty(value),continue;end

                changeField=true;
                if strcmp(field,'Progress')
                    if currentStatus.Progress~=value||value==100||value==0

                        elapsedTime=currentStatus.SimElapsedWallTime;
                        obj.updateStatus(runId,'SimElapsedWallTime',elapsedTime);
                        obj.LastSavedElapsedTime(runId)=elapsedTime;
                        changed=true;
                    end
                elseif strcmp(field,'SimStatus')
                    if(strcmp(value,message('Simulink:Engine:SimStatusRunning').getString())||...
                        strcmp(value,message('Simulink:Engine:SimStatusTerminating').getString()))
                        obj.updateStatus(runId,'StatusString',value);
                        changed=true;
                    end
                    if strcmp(value,obj.ActiveMsg)
                        obj.updateStatus(runId,'Status',value);
                        changedStatus=true;
                    elseif strcmp(value,obj.CompletedMsg)||...
                        strcmp(value,obj.ErrorsMsg)||...
                        strcmp(value,obj.CompletedWithWarningsMsg)
                        obj.Status(runId).SimStatus=value;
                        changeField=false;
                    elseif strcmp(value,obj.SimAndCallbacksCompletedMsg)
                        obj.updateStatus(runId,'Status',obj.Status(runId).SimStatus);
                        obj.Status(runId).SimStatus=value;
                        obj.FinalStatusReceived(runId)=true;
                        eventData=...
                        MultiSim.internal.SimulationManagerEventData(runId);
                        obj.notify('SimulationCompleted',eventData);
                        obj.JobStatusDBConfig.DrawNowThrottler.call();
                        changedStatus=true;
                        changeField=false;
                    end
                else
                    changed=true;
                end
                if changeField
                    obj.updateStatus(runId,field,value);
                end
            end

            if changedStatus||(changed&&currentStatus.Subscribed>0)
                obj.publishStatus(runId);
            end
        end

        function updateStatus(obj,runId,statusType,newVal)
            obj.Status(runId).(statusType)=newVal;
        end

        function details=getRunDetails(obj,runId)
            details=obj.Status(runId);
        end

        function updateFinalStatus(obj,runId,md)
            if~isempty(md.TimingInfo)
                obj.Status(runId).SimElapsedWallTime=md.TimingInfo.TotalElapsedWallTime;
                obj.SimMetadata(runId).TimingInfo=md.TimingInfo;
            end

            if~isempty(md.ExecutionInfo)
                execInfo=md.ExecutionInfo;
                obj.SimMetadata(runId).ExecutionInfo=execInfo;
            end
            obj.Status(runId).Progress=100;
            obj.publishDetails(runId);
        end

        function publishDetails(obj,runId)
            statusStruct=obj.Status(runId);
            statusStruct.SimMetadata=obj.SimMetadata(runId);
            message.publish(obj.RunDetailsChannel,statusStruct);
        end

        function publishStatus(obj,runId)
            obj.RunIdNeedsPublish(runId)=true;
            obj.NumUpdatesToPublish=obj.NumUpdatesToPublish+1;



            forceUpdate=(runId==obj.NumSims);
            obj.StatusUpdateThrottler.call('Force',forceUpdate);
        end

        function updateData(obj,simMonitorData,simMetadata)
            obj.NumWorkers=simMonitorData.NumWorkers;
            obj.IsRunning=false;
            obj.StartTime=simMonitorData.StartTime;
            stopTime=simMonitorData.FinishTime;
            if(stopTime==0)
                stopTime=[];
            end
            obj.StopTime=stopTime;

            for i=1:simMonitorData.SimulationRuns.Size
                simRun=simMonitorData.SimulationRuns(i);
                obj.Status(i).RunId=simRun.RunId;
                obj.Status(i).SimElapsedWallTime=simRun.SimElapsedWallTime;
                obj.Status(i).SimElapsedWallTimeNumeric=0;
                obj.Status(i).SimStatus=simRun.SimStatus;
                obj.Status(i).StatusString=simRun.StatusString;
                obj.Status(i).Status=simRun.State;
                obj.Status(i).Progress=simRun.Progress;
                obj.Status(i).Machine=simRun.Machine;
                obj.updateSimMetadata(i,simMetadata{i});
            end
            notify(obj,'DBChanged');
        end
    end

    methods(Access=private)
        function updateSimMetadata(obj,runId,simMetadata)
            simMetadataStruct=obj.SimMetadata(runId);
            simMetadataStruct.TimingInfo=simMetadata.TimingInfo;
            simMetadataStruct.ExecutionInfo=simMetadata.ExecutionInfo;
            obj.SimMetadata(runId)=simMetadataStruct;
        end

        function addListeners(obj,simMgr)
            listeners=[];
            listeners=[listeners,addlistener(simMgr,'JobStarted',@(~,~)obj.handleJobStart())];
            listeners=[listeners,addlistener(simMgr,'NumWorkersKnown',@obj.handleNumWorkersKnown)];

            listeners=[listeners,addlistener(simMgr,'JobFinished',@(~,~)obj.handleJobFinished())];
            obj.Listeners=listeners;
        end

        function handleSimManagerChange(obj,~,event)
            simMgr=event.AffectedObject.SimulationManager;
            obj.ModelName=simMgr.ModelName;
            obj.createDB(simMgr);
            obj.addListeners(simMgr);
        end

        function handleNumWorkersKnown(obj,~,event)
            eventData=event.Data;
            numWorkers=eventData.NumWorkers;
            isParallelRun=eventData.IsParallelRun;
            obj.NumWorkers=numWorkers;

            message.publish(obj.HeaderDataChannel,...
            struct('NumWorkers',numWorkers));


            mgr=slss.Manager;
            if~isempty(obj.SlssConnectionId)
                mgr.disconnect(obj.SlssConnectionId);
            end
            obj.SlssConnectionId=mgr.connect(@obj.ReceiveUpdatesCB,obj.ModelName,isParallelRun);
        end

        function createDB(obj,simMgr)
            obj.NumSims=length(simMgr.SimulationInputs);
            obj.NumWorkers=1;

            if obj.NumSims<100
                obj.SimElapsedRefreshRate=2.5;
            else
                obj.SimElapsedRefreshRate=10;
            end

            obj.RunIdNeedsPublish=false(1,obj.NumSims);
            obj.NumUpdatesToPublish=0;

            obj.Status=obj.DefaultStatus;
            obj.LastSavedElapsedTime=zeros(1,obj.NumSims);
            obj.FinalStatusReceived=false(1,obj.NumSims);




            if~isempty(obj.SlssListener)
                delete(obj.SlssListener);
                obj.SlssListener=[];
            end

            runStatus=obj.Status;
            if obj.NumSims>0
                obj.Status(1:obj.NumSims)=runStatus;
                obj.SimMetadata=repmat(obj.getDefaultSimMetadata(simMgr.ModelName),1,obj.NumSims);
                arrayfun(@(x)obj.assignRunId(x),1:obj.NumSims);
            end
            notify(obj,'DBChanged');
        end

        function handleJobStart(obj)
            obj.StartTime=now;
            obj.StopTime=[];
            obj.IsRunning=true;



            if~isempty(obj.SlssConnectionId)
                mgr=slss.Manager;
                mgr.disconnect(obj.SlssConnectionId);
                obj.SlssConnectionId=uint32.empty;
            end

            msg.NumSims=obj.NumSims;
            msg.IsRunning=true;
            msg.StartTimer=true;
            msg.Time=etime(datevec(now),datevec(obj.StartTime));
            message.publish(obj.HeaderDataChannel,msg);
        end

        function handleJobFinished(obj)
            forceUpdate=true;
            obj.StatusUpdateThrottler.call('Force',forceUpdate);
            obj.setExecutionStatus(false);
        end

        function assignRunId(obj,runId)
            obj.Status(runId).RunId=runId;
        end

        function setupConnector(obj,job)
            channelPrefix=['/MultiSimJob/',job.UUID];
            connector.ensureServiceOn;

            obj.HeaderDataChannel=[channelPrefix,'/headerData'];
            obj.RunDetailsChannel=[channelPrefix,'/runDetails'];
            obj.RunStatusChannel=[channelPrefix,'/runStatus'];
            obj.NotifyAppChannel=[channelPrefix,'/notifyApp'];

            runSubscriptionChannel=[channelPrefix,'/runSubscription'];
            obj.RunSubscriptionSub=message.subscribe(runSubscriptionChannel,@(x)obj.runSubscriptionHandler(x));
        end

        function finishPendingUpdates(obj)
            runIdsToPublish=find(obj.RunIdNeedsPublish);
            numRunIdsToPublish=numel(runIdsToPublish);
            outMsg(1:numRunIdsToPublish)=struct('RunId',[],...
            'SimElapsedWallTime',[],...
            'StatusString',[],'Status',[],'Progress',[],...
            'Machine',[]);
            for i=1:numRunIdsToPublish
                details=obj.Status(runIdsToPublish(i));
                outMsg(i).RunId=details.RunId;
                outMsg(i).SimElapsedWallTime=details.SimElapsedWallTime;
                outMsg(i).StatusString=details.StatusString;
                outMsg(i).Status=details.Status;
                outMsg(i).Progress=details.Progress;
                outMsg(i).Machine=details.Machine;
            end
            obj.RunIdNeedsPublish=false(1,obj.NumSims);
            obj.NumUpdatesToPublish=0;
            message.publish(obj.RunStatusChannel,outMsg);
            evtData=MultiSim.internal.SimulationManagerEventData(outMsg);
            notify(obj,'RunStatusUpdated',evtData);
        end
    end

    methods(Static)
        function md=getDefaultSimMetadata(modelName)
            timingInfoStruct=[];
            executionInfoStruct=[];

            if bdIsLoaded(modelName)
                pendingMsg=MultiSim.JobStatusDB.PendingMsg;
                metadataWrapper=Simulink.SimMetadataWrapper(modelName);
                metaStruct=metadataWrapper.matlabStruct(1);
                timingInfoStruct=metaStruct.TimingInfo;
                fieldNames=fields(timingInfoStruct);
                for i=1:numel(fieldNames)
                    timingInfoStruct.(fieldNames{i})=pendingMsg;
                end
                executionInfoStruct=struct('StopEvent',pendingMsg,...
                'StopEventDescription',pendingMsg);
            end
            md=struct('TimingInfo',timingInfoStruct,...
            'ExecutionInfo',executionInfoStruct);
        end
    end
end
