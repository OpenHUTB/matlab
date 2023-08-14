classdef Simulator<handle



    properties(Hidden,SetAccess=private)
Application
Timer
Scenario
ErrorHandler
    end

    properties



        SimulationMode='detections';
    end

    properties(Dependent)
SimulatorSpecification
    end

    methods
        function this=Simulator(hApp)
            this.Application=hApp;
            createTimer(this);
        end

        function value=get.SimulatorSpecification(this)
            value=this.Application.DataModel.SimulatorSpecification;
        end

        function delete(this)
            stopTimer(this);
            delete(this.Timer);
            delete@handle(this);
        end

        function goToStart(this)

            goToStart(this.SimulatorSpecification);
        end

        function stepForward(this)

            validateScenario(this);

            stepForward(this.SimulatorSpecification);
        end

        function stepBackward(this)

            stepBackward(this.SimulatorSpecification);
        end

        function play(this)

            if~isPlaybackRunning(this.SimulatorSpecification)

                validateScenario(this);

                startPlayback(this.SimulatorSpecification);
            end
        end

        function pause(this)

            pausePlayback(this.SimulatorSpecification);
        end

        function stopPlayback(this)
            if~isPlaybackStopped(this.SimulatorSpecification)


                stopPlayback(this.SimulatorSpecification);
            end
        end

        function togglePlay(this)
            if isPlaybackRunning(this.SimulatorSpecification)
                pause(this);
            else
                play(this);
            end
        end

        function stop(this)
            stopTimer(this);
            stopRecording(this.SimulatorSpecification);
            stopPlayback(this);
        end

        function clearSilently(this)
            stopTimer(this);
            this.Scenario=[];


            clearSilently(this.SimulatorSpecification);
        end

        function updateSimulatorStatus(this)
            setTimeStatus(this.Application,currentTimeString(this.SimulatorSpecification));
        end
    end

    methods(Access=private)
        function validateScenario(this)
            spec=this.SimulatorSpecification;
            if~spec.IsScenarioValid
                this.Scenario=generateScenario(this.Application.DataModel,this.SimulationMode);
                spec.IsScenarioValid=true;
                startRecording(this);
            end
        end

        function startRecording(this)
            startRecording(this.SimulatorSpecification);
        end
    end


    methods
        function onRecordLogged(this)
            updateSimulatorStatus(this);
        end

        function onRecordSelected(this)
            updateSimulatorStatus(this);
        end

        function onRecordStopped(this)
            if~isPlaybackRunning(this.SimulatorSpecification)
                stopTimer(this);
            end
        end

        function onRecordComplete(this)
            if~isPlaybackRunning(this.SimulatorSpecification)
                stopTimer(this);
            end
        end

        function onPlaybackRestarted(this)
            if~isRecordInProgress(this.SimulatorSpecification)
                stopTimer(this);
            end
        end

        function onPlaybackStarted(this)
            startTimer(this);
        end

        function onPlaybackPaused(this)
            if~isRecordInProgress(this.SimulatorSpecification)
                stopTimer(this);
            end
        end

        function onPlaybackStopped(this)
            if~isRecordInProgress(this.SimulatorSpecification)
                stopTimer(this);
                updateSimulatorStatus(this);
            end
        end

        function onPlatformsChanged(this)
            clearSilently(this);
            updateSimulatorStatus(this);
        end

        function onSensorsChanged(this)
            clearSilently(this);
            updateSimulatorStatus(this);
        end
    end


    methods(Access=private)
        function createTimer(this)

            errorHandler=fusion.internal.scenarioApp.ErrorHandler;
            errorHandler.PreambleID=strcat(this.Application.ResourceCatalog,'SimulatorErrorPreamble');
            errorHandler.CleanupFcn=@(ex)this.timerError;
            this.ErrorHandler=errorHandler;
            this.ErrorHandler.Debug=this.Application.Debug;

            this.Timer=timer(...
            'Name','SimulationDelay',...
            'ExecutionMode','fixedSpacing',...
            'TimerFcn',@this.timerTick,...
            'StopFcn',@this.timerStopped,...
            'BusyMode','queue',...
            'Period',0.01,...
            'ObjectVisibility','off');
        end

        function startTimer(this)
            t=this.Timer;
            if~matlab.lang.OnOffSwitchState(t.Running)
                start(t);
            end
        end

        function stopTimer(this)
            t=this.Timer;
            if~isempty(t)&&isvalid(t)&&matlab.lang.OnOffSwitchState(t.Running)
                stop(t)
            end
        end

        function timerTick(this,varargin)
            execute(this.ErrorHandler,@this.advanceTime)
        end

        function advanceTime(this)
            if isRecordInProgress(this.SimulatorSpecification)
                if advance(this.Scenario)
                    entry=generateRecordEntry(this);
                    logRecordEntry(this.SimulatorSpecification,entry);
                else
                    completeRecording(this.SimulatorSpecification);
                end
            end

            if isPlaybackRunning(this.SimulatorSpecification)

                advanceCurrentPlaybackRecord(this.SimulatorSpecification);
            end
        end

        function timerStopped(~,varargin)

        end

        function timerError(this,varargin)
            stopRecording(this.SimulatorSpecification);
            stopPlayback(this);
        end
    end


    methods
        function entry=generateRecordEntry(this)

            timeStamp=this.Scenario.SimulationTime;


            poses=platformPoses(this.Scenario);


            detections=getDetections(this);


            lookAngles=getLookAngles(this);


            entry=struct('SimulationMode',this.SimulationMode,...
            'SimulationTime',timeStamp,...
            'Poses',poses,...
            'LookAngles',lookAngles,...
            'DetectionPositions',{detections});
        end

        function lookAngles=getLookAngles(this)
            lookAngles=zeros(numel(this.Application.DataModel.SensorSpecifications),3);
            count=0;
            platforms=this.Scenario.Platforms;
            for iPlat=1:numel(platforms)
                platform=platforms{iPlat};
                sensors=platform.Sensors;
                nSensors=numel(sensors);
                for n=1:nSensors
                    sensor=sensors{n};
                    lookAngles(count+n,1)=sensor.SensorIndex;
                    if sensor.HasElevation
                        lookAngles(count+n,2:3)=sensor.LookAngle;
                    else
                        lookAngles(count+n,2)=sensor.LookAngle(1);
                    end
                end
                count=count+nSensors;
            end
        end

        function detections=getDetections(this)
            [detections,~,~]=detect(this.Scenario);
            if isempty(detections)
                detections=cell(0,1);
            end
        end
    end
end