classdef GroundTruth<sim3d.sensors.Sensor

    properties(Access=protected)
        SignalReader=[];
        SensorWriter=[];
        SensorConfiguration='APlayerStart,AStaticMeshActor,ASim3dActor';
    end


    properties(Constant=true)
        MaxSignalSize=uint32(32*1024);

        SensorConfig='/GroundTruthSensor_OUT';
        SensorSignal='/GroundTruthSignal_IN';
        SensorConfigQueueDepth=1
        SensorSignalQueueDepth=256
    end


    methods

        function self=GroundTruth(sensorID,vehicleID,configuration,transform)
            sensorName=sim3d.sensors.Sensor.getSensorName('GroundTruth',sensorID);
            self@sim3d.sensors.Sensor(sensorName,vehicleID,transform);
            self.SensorConfiguration=configuration;
        end


        function setup(self)
            setup@sim3d.sensors.Sensor(self);
            self.SignalReader=sim3d.io.Subscriber([self.getTag(),sim3d.sensors.GroundTruth.SensorSignal],...
            'QueueDepth',sim3d.sensors.GroundTruth.SensorSignalQueueDepth);
            self.SensorWriter=sim3d.io.Publisher([self.getTag(),sim3d.sensors.GroundTruth.SensorConfig],...
            'QueueDepth',sim3d.sensors.GroundTruth.SensorConfigQueueDepth);
        end


        function reset(self)
            reset@sim3d.sensors.Sensor(self);
            self.SensorWriter.publish(uint8(self.SensorConfiguration));
        end


        function truth=read(self)
            truth={};
            while(self.SignalReader.has_message())
                groundTruthSignal=self.SignalReader.take();
                someTruth=eval(char(groundTruthSignal));
                truth{end+1}=someTruth;%#ok
            end
        end


        function delete(self)
            if~isempty(self.SignalReader)
                self.SignalReader.delete();
                self.SignalReader=[];
            end

            if~isempty(self.SensorWriter)
                self.SensorWriter.delete();
                self.SensorWriter=[];
            end
            delete@sim3d.sensors.Sensor(self);
        end

    end


    methods(Static)
        function tagName=getTagName()
            tagName='GroundTruth';
        end
    end


    methods(Access=public,Hidden=true)

        function actorType=getActorType(~)
            actorType=sim3d.utils.ActorTypes.GroundTruth;
        end
    end
end

