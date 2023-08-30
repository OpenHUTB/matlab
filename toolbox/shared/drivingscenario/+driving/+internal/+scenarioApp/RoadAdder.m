classdef RoadAdder<driving.internal.scenarioApp.Adder

    methods
        function this=RoadAdder(hApplication)
            this.Application=hApplication;
        end


        function addViaWaypoints(this,spec)
            hApp=this.Application;
            hScenario=hApp.ScenarioView;
            focusOnComponent(hApp.ScenarioView);
            hSensorCanvas=hApp.SensorCanvas;
            if~isempty(hSensorCanvas)
                hSensorCanvas.InteractionMode='move';
            end
            pause(0.1);

            if~isnumeric(spec)
                spec.Name=getUniqueName(this,spec.Name);
            end
            hScenario.addRoadCenters(spec);
            setStatus(hApp,getString(message('driving:scenarioApp:AddRoadCentersMessage')));
        end
    end


    methods(Access=protected)
        function specs=getCurrentSpecifications(this)
            specs=this.Application.RoadSpecifications;
        end
    end
end


