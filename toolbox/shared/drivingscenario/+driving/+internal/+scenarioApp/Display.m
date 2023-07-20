classdef Display<matlabshared.application.Application&...
    matlabshared.application.DynamicTabs




    properties
        Scenario;
Simulator
    end

    properties(SetObservable)
        EgoCarId;
    end

    properties(SetAccess='protected',Hidden)
        AllSimulators=driving.internal.scenarioApp.Simulator.empty;
ScenarioView
EgoCentricView
        CloseRequested=false;
        ShowSimulators=false;
    end

    properties(Hidden)
        IsUpdateAllowed=true;
    end

    properties(Access=protected)
SimulatorSampleChangedListener
    end

    methods
        function this=Display(varargin)
            this@matlabshared.application.Application(varargin{:});
        end

        function set.Scenario(this,newScenario)




            this.IsUpdateAllowed=false;%#ok<MCSUP>
            this.Scenario=newScenario;
            sim=this.Simulator;%#ok<MCSUP>
            if~isempty(sim)
                updateScenario(sim,newScenario);
            end
            this.IsUpdateAllowed=true;%#ok<MCSUP>
            updatePlots(this);
        end

        function l=addPropertyListener(this,prop,callback)
            l=event.proplistener(this,this.findprop(prop),'PostSet',callback);
        end

        function t=getTag(~)
            t='scenarioAppDisplay';
        end

        function set.Simulator(this,newSim)
            oldSim=this.Simulator;
            if~isempty(oldSim)
                detach(oldSim);
            end
            this.Simulator=newSim;
            if this.ShowSimulators
                this.DynamicTabController=newSim;
            end
            onSimulatorChanged(this);
            this.SimulatorSampleChangedListener=addSampleChangedListener(newSim,@this.onSimulatorSampleChanged);
            attach(newSim);
        end

        function open(this)
            open@matlabshared.application.Application(this);
            updateDynamicTabs(this);
        end
    end

    methods(Hidden)

        function onSimulatorSampleChanged(this,~,~)
            if this.IsUpdateAllowed
                scenarioView=this.ScenarioView;
                oldEnable=scenarioView.EnablePlotWaypointsUpdate;
                scenarioView.EnablePlotWaypointsUpdate=false;
                updateActor(this.ScenarioView);
                updateActor(this.EgoCentricView);
                scenarioView.EnablePlotWaypointsUpdate=oldEnable;
            end
        end

        function updateView(this)

            scenario=this.ScenarioView;
            egoCentric=this.EgoCentricView;
            toolGroup=this.ToolGroup.Name;

            md=com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
            md.setDocumentArrangement(toolGroup,md.TILED,java.awt.Dimension(2,1))


            md.setDocumentColumnWidths(toolGroup,[0.65,0.35]);


            md.setClientLocation(scenario.getName(),toolGroup,...
            com.mathworks.widgets.desk.DTLocation.create(0));

            md.setClientLocation(egoCentric.getName(),toolGroup,...
            com.mathworks.widgets.desk.DTLocation.create(1));


            set([scenario.Figure,egoCentric.Figure],'Visible','on');
        end

        function approveClose(this)
            simulator=this.Simulator;
            if~isvalid(simulator)||isStopped(simulator)||isPaused(simulator)
                approveClose@matlabshared.application.Application(this);
            else
                this.CloseRequested=true;
                stop(simulator);
            end
        end

        function finalizeClose(this)
            delete(this.Simulator);
            deleteTimeStampTimer(this.ScenarioView);
            finalizeClose@matlabshared.application.Application(this);
        end

        function varargout=initSimulator(this,className)
            allSims=this.AllSimulators;
            sim=findobj(allSims,'-isa',className);
            if isempty(sim)
                sim=feval(className,this);
                allSims(end+1)=sim;
                this.AllSimulators=allSims;
            end
            if nargout>0
                varargout={sim};
            else
                this.Simulator=sim;
            end
        end
    end

    methods(Access=protected)

        function onSimulatorChanged(~)

        end

        function updateComponents(this)
            updatePlots(this);
            updateView(this);
        end

        function f=createDefaultComponents(this)
            this.ScenarioView=driving.internal.scenarioApp.ScenarioView(this);
            this.EgoCentricView=driving.internal.scenarioApp.EgoCentricView(this);

            f=[this.EgoCentricView,this.ScenarioView];
        end

        function updatePlots(this)
            if~isempty(this.ScenarioView)
                update(this.ScenarioView);
            end
            if~isempty(this.EgoCentricView)
                update(this.EgoCentricView);
            end
        end

        function updatePlotsForActors(this)
            if~isempty(this.ScenarioView)
                updateActor(this.ScenarioView,[],true);
            end
            if~isempty(this.EgoCentricView)
                updateActor(this.EgoCentricView,[],true);
            end
        end

        function parseInputs(this,scenario,egoCarId)
            if nargin<2
                scenario=drivingScenario;
            end
            this.Scenario=scenario;
            this.Simulator=initSimulator(this,'driving.internal.scenarioApp.ScenarioSimulator');
            if nargin<3
                actors=scenario.Actors;
                if isempty(actors)
                    egoCarId=[];
                else
                    egoCarId=actors(1).ActorID;
                end
            end
            this.EgoCarId=egoCarId;
        end
    end
end
