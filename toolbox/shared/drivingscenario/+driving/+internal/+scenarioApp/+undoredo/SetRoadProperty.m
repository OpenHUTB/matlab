classdef SetRoadProperty<driving.internal.scenarioApp.undoredo.SetProperty
    properties(SetAccess=protected)
        OldSim3dScene;
    end

    methods
        function this=SetRoadProperty(varargin)
            this@driving.internal.scenarioApp.undoredo.SetProperty(varargin{:});
            this.OldSim3dScene=this.Application.Sim3dScene;
        end

        function execute(this)
            execute@driving.internal.scenarioApp.undoredo.SetProperty(this);
            this.Application.Sim3dScene='';
        end

        function undo(this)
            undo@driving.internal.scenarioApp.undoredo.SetProperty(this);
            this.Application.Sim3dScene=this.OldSim3dScene;
        end

        function updateScenario(this)
            hApp=this.Application;
            roadCreationStarting(hApp);
            generateNewScenarioFromSpecifications(this.Application);
            roadCreationFinished(hApp);

            notify(hApp,'RoadPropertyChanged',driving.internal.scenarioApp.PropertyChangedEventData(this.Object,this.Property));
        end
    end
end


