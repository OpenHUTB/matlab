classdef BarrierAdder<driving.internal.scenarioApp.Adder

    methods

        function this=BarrierAdder(hApplication)
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
            hScenario.addBarrierCenters(spec);

            setStatus(hApp,getString(message('driving:scenarioApp:AddBarrierCentersMessage')));
        end
    end


    methods(Access=protected)
        function specs=getCurrentSpecifications(this)
            specs=this.Application.BarrierSpecifications;
        end
    end
end


