classdef SetBarrierProperty<driving.internal.scenarioApp.undoredo.SetProperty
    methods
        function this=SetBarrierProperty(varargin)
            this@driving.internal.scenarioApp.undoredo.SetProperty(varargin{:});
        end

        function updateScenario(this)
            hApp=this.Application;
            generateNewScenarioFromSpecifications(this.Application);

            notify(hApp,'BarrierPropertyChanged',driving.internal.scenarioApp.PropertyChangedEventData(this.Object,this.Property));
        end
    end
end


