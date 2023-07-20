classdef SetActorProperty<driving.internal.scenarioApp.undoredo.SetProperty
    methods
        function this=SetActorProperty(varargin)
            this@driving.internal.scenarioApp.undoredo.SetProperty(varargin{:});
        end
        function updateScenario(this)
            app=this.Application;
            allSpecs=app.ActorSpecifications;
            [~,~,index]=intersect(this.Object,allSpecs);
            updateActorInScenario(app,index);

            notify(app,'ActorPropertyChanged',driving.internal.scenarioApp.PropertyChangedEventData(this.Object,this.Property));
        end
    end
end


