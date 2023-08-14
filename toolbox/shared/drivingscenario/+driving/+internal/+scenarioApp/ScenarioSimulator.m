% 进行场景仿真：可用于启动仿真
classdef ScenarioSimulator<driving.internal.scenarioApp.Simulator

    properties(SetAccess=protected)
        Player
    end

    properties(SetAccess=protected,Hidden)
        SimulateSection;
    end

    methods
        function this=ScenarioSimulator(app)
            this@driving.internal.scenarioApp.Simulator(app)
            this.Player=driving.internal.scenarioApp.ScenarioPlayer(app.Scenario);
            this.Tag='scenario';
        end


        function s=serialize(this)
            player=this.Player;
            s.Repeat=player.Repeat;
            s.StopCondition=player.StopCondition;
            s.StopTime=player.StopTime;
        end


        function deserialize(this,s)
            player=this.Player;
            player.Repeat=s.Repeat;
            player.StopCondition=s.StopCondition;
            player.StopTime=s.StopTime;
        end


        function clearCaches(this)
            clearNumSamples(this.Player);
        end


        function updateScenario(this,newScenario)
            this.Player.Scenario=newScenario;
        end


        function delete(this)
            delete(this.Player);
        end


        function s=getCurrentSample(this)
            s=this.Player.CurrentSample;
        end


        function t=getCurrentTime(this)
            t=getCurrentTime(this.Player);
        end


        function t=getStopTime(this)
            t=getStopTime(this.Player);
        end


        function b=isPaused(this)
            b=this.Player.IsPaused;
        end


        function b=isStopped(this)
            b=isStopped(this.Player);
        end


        function b=isRunning(this)
            b=this.Player.IsPlaying;
        end


        % % 开始仿真（相当于点击驾驶场景设计器菜单中的运行）
        % designer.Simulator.run()
        function run(this)
            play(this.Player);
        end


        function stop(this)
            stop(this.Player);
        end


        function pause(this)
            pause(this.Player);
        end


        function stepForward(this)
            stepForward(this.Player);
        end


        function stepBackward(this)
            stepBackward(this.Player);
        end


        function reset(this)
            reset(this.Player);
        end


        function updateToolstrip(this)
            ss=this.SimulateSection;
            if~isempty(ss)
                update(this.SimulateSection);
            end
        end


        function l=addStateChangedListener(this,cb)
            l=event.listener(this.Player,'StateChanged',cb);
        end


        function l=addSampleChangedListener(this,cb)
            l=event.listener(this.Player,'SampleChanged',cb);
        end


        function b=canRun(this)
            app=this.Designer;
            scenario=app.Scenario;
            if isempty(scenario)
                b=false;
            else
                actors=scenario.Actors;
                b=~isempty(app.RoadSpecifications)&&~isempty(actors);
            end
            if b
                hasMotion=false;
                for indx=1:numel(actors)
                    motion=actors(indx).MotionStrategy;
                    hasMotion=hasMotion||isa(motion,'driving.scenario.Path')&&~isempty(motion.Waypoints);
                end
                b=hasMotion;
            end
        end


        function i=getIcon(~)
            i=matlab.ui.internal.toolstrip.Icon.MATLAB_24;
        end


        function attach(this)
            ss=this.SimulateSection;
            if~isempty(ss)
                attach(ss);
            end
        end


        function detach(this)
            ss=this.SimulateSection;
            if~isempty(ss)
                detach(ss);
            end
        end

    end

    
    methods(Access=protected)
        function s=getSections(this)
            s=this.SimulateSection;
            if~isempty(s)&&isvalid(s)
                delete(s);
            end
            s=driving.internal.scenarioApp.SimulateSection(this.Designer);
            this.SimulateSection=s;
            attach(s);
        end
    end
end
