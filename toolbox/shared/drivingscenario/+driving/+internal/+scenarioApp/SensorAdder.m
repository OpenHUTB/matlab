classdef SensorAdder<driving.internal.scenarioApp.Adder




    methods
        function this=SensorAdder(app)
            this.Application=app;
        end

        function addViaMouse(this,type)

            switch type
            case 'radar'
                name=getString(message('driving:scenarioApp:DefaultRadarName'));
            case 'vision'
                name=getString(message('driving:scenarioApp:DefaultVisionName'));
            case 'lidar'
                name=getString(message('driving:scenarioApp:DefaultLidarName'));
            case 'ins'
                name=getString(message('driving:scenarioApp:DefaultINSName'));
            case 'ultrasonic'
                name=getString(message('driving:scenarioApp:DefaultUltrasonicName'));
            end
            designer=this.Application;
            sensorCanvas=getSensorCanvasComponent(designer);
            focusOnComponent(sensorCanvas);
            pause(0.2);
            exitInteractionMode(designer.ScenarioView);
            enableAddSensor(sensorCanvas,type,'Name',getUniqueName(this,name));
        end
    end

    methods(Access=protected)
        function specs=getCurrentSpecifications(this)
            specs=this.Application.SensorSpecifications;
        end
    end
end


