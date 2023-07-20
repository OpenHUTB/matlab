classdef SetActorPosition<driving.internal.scenarioApp.undoredo.SetActorProperty
    methods

        function this=SetActorPosition(hApp,actor,position,varargin)
            this@driving.internal.scenarioApp.undoredo.SetActorProperty(...
            hApp,actor,'Position',position,varargin{:});
        end

        function updateScenario(this)
            actor=this.Object;

            for indx=1:numel(actor)
                if~isempty(actor(indx).Waypoints)
                    actor(indx).Waypoints(1,:)=actor(indx).Position;
                end
            end

            updateScenario@driving.internal.scenarioApp.undoredo.SetActorProperty(this);
            app=this.Application;
            canvas=app.ScenarioView;
            if strcmp(canvas.InteractionMode,'addActorWaypoints')
                updateAddActorWaypointsCursorLine(canvas);
            end
            notify(app,'ActorPropertyChanged',driving.internal.scenarioApp.PropertyChangedEventData(this.Object,this.Property));
        end

        function str=getDescription(~)
            str=getString(message('driving:scenarioApp:MoveActorText'));
        end
    end
end


