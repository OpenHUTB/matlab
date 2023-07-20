classdef SimulatorSpecification<fusion.internal.scenarioApp.dataModel.Specification

    properties

StopTime
UpdateRate


TotalTime
IsScenarioValid
ScenarioName
    end

    properties(SetAccess=private)
Record
PlaybackStatus
RecordStatus
IsSimulationFinite
    end

    properties(Dependent)
CurrentRecordIndex
    end

    properties(SetAccess=private)
pCurrentRecordIndex
    end

    properties(Constant)
        PadDuration=1000
    end

    events
RecordStopped
RecordStarted
RecordComplete
RecordLogged
RecordSelected
PlaybackRestarted
PlaybackStopped
PlaybackStarted
PlaybackPaused
    end

    methods
        function this=SimulatorSpecification(varargin)
            this@fusion.internal.scenarioApp.dataModel.Specification(varargin{:});
            reset(this);
        end

        function reset(this)
            this.StopTime=Inf;
            this.UpdateRate=1;

            this.TotalTime=0;
            this.IsScenarioValid=false;
            this.ScenarioName='scenario';

            this.Record=[];
            this.PlaybackStatus='stopped';
            this.RecordStatus='stopped';
            this.IsSimulationFinite=false;

            this.pCurrentRecordIndex=0;
        end

        function applyToScenario(this,scenario)
            pvPairs=toPvPairs(this);
            for indx=1:2:numel(pvPairs)
                scenario.(pvPairs{indx})=pvPairs{indx+1};
            end
        end

        function pvPairs=toPvPairs(this)
            pvPairs={
            'StopTime',this.StopTime,...
            'UpdateRate',this.UpdateRate};
        end

        function importScenario(this,scenario,wHandler)
            if isfinite(scenario.StopTime)
                wHandler.addMessage('ScenarioStopTimeIgnored');
            end
            this.StopTime=Inf;

            if scenario.UpdateRate~=0
                wHandler.addMessage('ScenarioUpdateRateIgnored');
            end
            this.UpdateRate=0;
        end

        function str=generateMatlabCode(this,hasSensors)
            sceneName=this.ScenarioName;
            if hasSensors
                updateRate=0;
            else
                updateRate=this.UpdateRate;
            end

            str=vertcat("% Create Scenario",...
            sceneName+" = trackingScenario;",...
            sceneName+".StopTime = "+mat2str(this.StopTime)+";",...
            sceneName+".UpdateRate = "+mat2str(updateRate)+";",...
            "");
        end

        function initTotalTime(this,value)
            this.IsSimulationFinite=isfinite(value);
            if this.IsSimulationFinite
                this.TotalTime=value;
            else
                this.TotalTime=this.PadDuration;
            end
        end

    end


    methods
        function flag=isRecordStopped(this)
            flag=strcmp(this.RecordStatus,'stopped');
        end

        function flag=isRecordInProgress(this)
            flag=strcmp(this.RecordStatus,'recording');
        end

        function flag=isRecordComplete(this)
            flag=strcmp(this.RecordStatus,'complete');
        end

        function flag=isPlaybackStopped(this)
            flag=strcmp(this.PlaybackStatus,'stopped');
        end

        function flag=isPlaybackPaused(this)
            flag=this.CurrentRecordIndex>0&&strcmp(this.PlaybackStatus,'paused');
        end

        function flag=isPlaybackRunning(this)
            flag=strcmp(this.PlaybackStatus,'running');
        end

        function flag=isPlaybackStarted(this)
            flag=this.CurrentRecordIndex>0;
        end

        function flag=isPlaybackComplete(this)
            flag=this.CurrentRecordIndex==numel(this.Record);
        end

        function[start,stop,total]=recordLimits(this)
            if isempty(this.Record)
                start=NaN;
                stop=NaN;
                total=this.PadDuration;
            else
                start=this.Record(1).SimulationTime;
                stop=this.Record(end).SimulationTime;
                total=this.TotalTime;
            end
        end
    end


    methods
        function value=get.CurrentRecordIndex(this)
            value=this.pCurrentRecordIndex;
        end

        function set.CurrentRecordIndex(this,value)
            this.pCurrentRecordIndex=value;
            notify(this,'RecordSelected');
        end

        function set.RecordStatus(this,value)
            validatestring(value,{'stopped','recording','complete'});
            this.RecordStatus=value;
        end

        function set.PlaybackStatus(this,value)
            validatestring(value,{'stopped','running','paused'});
            this.PlaybackStatus=value;
        end
    end

    methods(Access=private)
        function clearRecordSilently(this)
            this.Record=[];
            this.pCurrentRecordIndex=0;
            this.RecordStatus='stopped';
        end

        function clearPlaybackSilently(this)
            this.pCurrentRecordIndex=0;
            this.PlaybackStatus='stopped';
        end
    end

    methods

        function startRecording(this)
            clearRecordSilently(this);
            this.RecordStatus='recording';
            notify(this,'RecordStarted');
        end

        function stopRecording(this)
            clearRecordSilently(this);
            this.RecordStatus='stopped';
            notify(this,'RecordStopped');
        end

        function completeRecording(this)
            this.RecordStatus='complete';
            notify(this,'RecordComplete');
        end


        function pausePlayback(this)
            if isPlaybackRunning(this)
                this.PlaybackStatus='paused';
                notify(this,'PlaybackPaused');
            end
        end

        function stopPlayback(this)
            this.IsScenarioValid=false;
            this.pCurrentRecordIndex=0;
            this.PlaybackStatus='stopped';
            notify(this,'PlaybackStopped');
        end

        function goToStart(this)
            if isPlaybackRunning(this)
                pausePlayback(this);
            end

            this.pCurrentRecordIndex=0;
            notify(this,'PlaybackRestarted');
        end

        function stepBackward(this)
            if this.CurrentRecordIndex>0
                this.PlaybackStatus='paused';
                this.CurrentRecordIndex=this.CurrentRecordIndex-1;
            end
        end

        function startPlayback(this)
            if~isPlaybackRunning(this)
                if this.CurrentRecordIndex==numel(this.Record)
                    this.pCurrentRecordIndex=0;
                end
                this.PlaybackStatus='running';
                notify(this,'PlaybackStarted');
            end
        end

        function stepForward(this)
            if this.CurrentRecordIndex<numel(this.Record)
                this.PlaybackStatus='paused';
                this.CurrentRecordIndex=this.CurrentRecordIndex+1;
            end
        end

        function advanceCurrentPlaybackRecord(this)
            if this.CurrentRecordIndex<numel(this.Record)

                this.CurrentRecordIndex=this.CurrentRecordIndex+1;
            end

            if isRecordComplete(this)&&this.CurrentRecordIndex==numel(this.Record)
                pausePlayback(this);
            end
        end

        function setNewSimulationTime(this,newTime)
            if~isempty(this.Record)
                pausePlayback(this);
                idx=find(vertcat(this.Record(:).SimulationTime)<=newTime,1,'last');
                if isempty(idx)
                    idx=1;
                end
                this.CurrentRecordIndex=idx;
            end
        end

        function t=currentTime(this)
            record=this.Record;
            if isempty(record)
                t=NaN;
            elseif this.CurrentRecordIndex==0
                t=0;
            else
                t=this.Record(this.CurrentRecordIndex).SimulationTime;
            end
        end

        function str=currentTimeString(this)
            current=currentTime(this);
            if isnan(current)
                str='';
            else
                str=sprintf('T = %.2f / %.2f',current,this.TotalTime);
            end
        end

        function clearSilently(this)
            this.IsScenarioValid=false;
            clearRecordSilently(this);
            clearPlaybackSilently(this);
        end

        function logRecordEntry(this,entry)
            if isempty(this.Record)
                this.Record=entry;
            else
                this.Record(end+1)=entry;
                if entry.SimulationTime>this.TotalTime
                    if this.IsSimulationFinite
                        this.TotalTime=entry.SimulationTime;
                    else
                        this.TotalTime=ceil(entry.SimulationTime/this.PadDuration)*this.PadDuration;
                    end
                end
            end

            notify(this,'RecordLogged');
        end

        function entry=currentEntry(this)
            if isempty(this.Record)||this.CurrentRecordIndex==0
                entry=[];
            else
                entry=this.Record(this.CurrentRecordIndex);
            end
        end

        function entries=entryHistory(this,numEntry)


            if isempty(this.Record)||this.CurrentRecordIndex==0
                entries=[];
            elseif this.CurrentRecordIndex<numEntry
                entries=this.Record(1:this.CurrentRecordIndex);
            else
                entries=this.Record(this.CurrentRecordIndex-numEntry+1:this.CurrentRecordIndex);
            end
        end

    end
end
