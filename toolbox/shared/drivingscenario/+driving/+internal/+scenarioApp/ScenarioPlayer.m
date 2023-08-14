classdef ScenarioPlayer<handle

    properties
        Scenario;
        Repeat=false;
        PauseAtSample='end'


        StopCondition='first';
        StopTime=10;
    end

    properties(SetAccess=protected)
        IsPlaying=false;
        IsPaused=false;
        CurrentSample=1;
        NumSamples=NaN;
    end

    properties(Access=protected)
        Timer;
    end

    events(NotifyAccess=protected,ListenAccess=public)
StateChanged
SampleChanged
    end

    methods
        function this=ScenarioPlayer(scenario)
            this.Scenario=scenario;
        end

        function set.StopCondition(this,newCondition)
            this.StopCondition=newCondition;
            setupScenario(this);
        end

        function set.StopTime(this,newTime)
            this.StopTime=newTime;
            if strcmp(this.StopCondition,'time')
                setupScenario(this);
            end
        end

        function delete(this)
            t=this.Timer;
            if~isempty(t)&&isvalid(t)
                if strcmp(t.Running,'on')
                    stop(t);
                end
                delete(t);
            end
        end

        function stopTime=getStopTime(this)
            if strcmp(this.StopCondition,'time')
                stopTime=this.StopTime;
            else
                stopTime=inf;
            end
        end

        function set.Scenario(this,newScenario)


            stop(this);
            this.Scenario=newScenario;

            setupScenario(this);
            this.CurrentSample=1;%#ok<*MCSUP>
            notify(this,'StateChanged');
            notify(this,'SampleChanged');
        end

        function clearNumSamples(this)

            setupScenario(this);
            this.CurrentSample=1;
            notify(this,'StateChanged');
        end

        function stepForward(this)
            pause(this);
            sample=this.CurrentSample;
            if sample==this.NumSamples
                sample=1;
            else
                sample=sample+1;
            end



            setCurrentSample(this,sample);


            notify(this,'StateChanged');
        end

        function stepBackward(this)
            pause(this);
            newSample=this.CurrentSample-1;
            if newSample<1
                return;
            end

            this.CurrentSample=newSample;

            setCurrentSample(this,newSample);


            notify(this,'StateChanged');
        end

        function isRunning=setCurrentSample(this,newSample)
            this.CurrentSample=newSample;
            scenario=this.Scenario;


            newTime=(newSample-1)*scenario.SampleTime;


            isRunning=move(scenario.Actors,newTime);

            if strcmp(this.StopCondition,'time')
                isRunning=newTime+scenario.SampleTime<=this.StopTime;
            elseif strcmp(this.StopCondition,'first')
                isRunning=all(isRunning);
            else

                isRunning=any(isRunning(~arrayfun(@(e)isa(e.MotionStrategy,'driving.scenario.Stationary'),scenario.Actors)));
            end

            if~isRunning
                this.NumSamples=newSample;
            end

            if~this.IsPlaying
                this.IsPaused=~(newSample==1||newSample==this.NumSamples);
            end


            notify(this,'SampleChanged');
        end

        function play(this)


            if this.IsPlaying
                return;
            end
            t=this.Timer;
            if isempty(t)||~isvalid(t)


                t=timer(...
                'Tag','ScenarioPlayerSimulationStep',...
                'ExecutionMode','fixedSpacing',...
                'TimerFcn',@this.timerTick,...
                'StopFcn',@this.stopFcn,...
                'BusyMode','queue',...
                'Period',0.01,...
                'ObjectVisibility','off');
                this.Timer=t;
            end



            if this.IsPaused
                this.IsPaused=false;
            end
            this.IsPlaying=true;
            notify(this,'StateChanged');
            if this.CurrentSample==1
                setupScenario(this);
            end
            if strcmp(t.Running,'off')
                start(t);
            end
        end

        function pause(this)
            this.IsPlaying=false;
            this.IsPaused=true;

            stopTimer(this);
        end

        function stop(this)
            this.IsPlaying=false;
            this.IsPaused=false;
            stopTimer(this);
        end

        function b=isStopped(this)
            b=~(this.IsPlaying||this.IsPaused&&this.CurrentSample~=1);
        end

        function reset(this)
            setupScenario(this);
            setCurrentSample(this,1);
            notify(this,'StateChanged');
        end

        function samples=getNumSamples(this)


            samples=this.NumSamples;
        end

        function time=getCurrentTime(this)
            time=this.Scenario.SampleTime*(this.CurrentSample-1);
        end
    end

    methods(Access=protected)

        function setupScenario(this)
            scenario=this.Scenario;
            if strcmp(this.StopCondition,'time')
                this.NumSamples=floor(this.StopTime/scenario.SampleTime)+1;
            else
                this.NumSamples=NaN;
            end
        end

        function stopTimer(this)
            t=this.Timer;
            if isempty(t)||~isvalid(t)||strcmp(t.Running,'off')
                return;
            end
            stop(t);
        end

        function stopFcn(this,varargin)
            notify(this,'StateChanged');
        end

        function timerTick(this,varargin)

            sample=this.CurrentSample;

            if sample==this.NumSamples
                sample=1;
            else
                sample=sample+1;
            end


            isRunning=setCurrentSample(this,sample)&&sample~=this.NumSamples;




            if sample==1
                notify(this,'StateChanged');
            end
            if sample>=getPauseAtSample(this)
                pause(this);
            elseif~isRunning




                if sample~=this.NumSamples
                    this.NumSamples=sample;
                end




                if~this.Repeat



                    stop(this);
                end
            end
        end

        function sample=getPauseAtSample(this)
            sample=this.PauseAtSample;
            if strcmp(sample,'end')
                sample=Inf;
            end
        end
    end
end


