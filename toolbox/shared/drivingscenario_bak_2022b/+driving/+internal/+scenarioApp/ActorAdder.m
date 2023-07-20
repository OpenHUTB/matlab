classdef ActorAdder<driving.internal.scenarioApp.Adder



    methods
        function this=ActorAdder(hApplication)
            this.Application=hApplication;
        end

        function addViaMouse(this,spec)
            if nargin>1&&isstruct(spec)
                spec.Name=getUniqueName(this,spec.name);
                spec.ClassID=spec.id;
                spec=rmfield(spec,{'id','isVehicle','isMovable','name'});
            else
                spec=struct;
            end
            hApp=this.Application;
            hScenario=hApp.ScenarioView;
            focusOnComponent(hScenario);
            hSensorCanvas=hApp.SensorCanvas;
            if~isempty(hSensorCanvas)
                hSensorCanvas.InteractionMode='move';
            end
            if isempty(spec.PlotColor)
                spec.PlotColor=driving.scenario.Actor.getDefaultColorForActorID(hApp.ActorCount+1);
            end
            pause(0.1);

            hScenario.addActor(spec);
            hScenario.focusOnComponent;
        end

        function addWaypoints(this,actorID)
            hApplication=this.Application;
            hScenario=hApplication.ScenarioView;

            hScenario.addActorWaypoints(actorID);
            hScenario.focusOnComponent;
            setStatus(hApplication,getString(message('driving:scenarioApp:AddWaypointsMessage')));
        end
    end

    methods(Access=protected)
        function specs=getCurrentSpecifications(this)
            specs=this.Application.ActorSpecifications;
        end
    end
end


