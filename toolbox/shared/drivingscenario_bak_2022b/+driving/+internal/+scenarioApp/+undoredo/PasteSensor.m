classdef PasteSensor<driving.internal.scenarioApp.undoredo.Edit
    properties(SetAccess=protected)
Sensor
    end

    methods
        function this=PasteSensor(app,Sensor)
            this.Application=app;
            this.Sensor=Sensor;
        end

        function execute(this)


            app=this.Application;
            sensor=this.Sensor;
            addSensorSpecification(app,sensor);
            updateForSensors(app,sensor);
        end

        function undo(this)
            app=this.Application;
            sensor=this.Sensor;
            index=find(app.SensorSpecifications==sensor);
            deleteSensor(app,index);
        end

        function str=getDescription(this)
            str=getString(message('Spcuilib:application:PasteObject',this.Sensor.Name));
        end
    end
end


