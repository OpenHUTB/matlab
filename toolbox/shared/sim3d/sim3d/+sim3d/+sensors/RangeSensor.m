classdef RangeSensor<sim3d.sensors.Sensor

    properties(Access=protected)
        Range(1,1)single{mustBeNonnegative};
        HorizontalFOV(1,1)single{mustBeNonnegative,mustBeLessThanOrEqual(HorizontalFOV,3.141592653589793)};
        VerticalFOV(1,1)single{mustBeNonnegative,mustBeLessThanOrEqual(VerticalFOV,3.141592653589793)};

        SensorConfigPublisher=[];
        SensorSignalSubscriber=[];
    end


    properties(Constant)
        ConfigSuffix='/RangeSensorConfig';
        SignalSuffix='/RangeSensorSignal';
    end


    methods

        function self=RangeSensor(sensorID,vehicleID,sensorProperties,transform)
            sensorName=sim3d.sensors.Sensor.getSensorName('RangeSensor',sensorID);
            self@sim3d.sensors.Sensor(sensorName,vehicleID,transform);
            self.Range=sensorProperties.Range;
            self.HorizontalFOV=sensorProperties.HorizontalFOV;
            self.VerticalFOV=sensorProperties.VerticalFOV;
        end


        function setup(self)
            setup@sim3d.sensors.Sensor(self);
            self.SensorConfigPublisher=sim3d.io.Publisher([self.getTag(),sim3d.sensors.RangeSensor.ConfigSuffix]);
            self.SensorSignalSubscriber=sim3d.io.Subscriber([self.getTag(),sim3d.sensors.RangeSensor.SignalSuffix]);
        end


        function reset(self)
            reset@sim3d.sensors.Sensor(self);
            self.SensorConfigPublisher.publish(...
            struct(...
            'Range',self.Range,...
            'HorizontalFieldOfView',self.HorizontalFOV,...
            'VerticalFieldOfView',self.VerticalFOV...
            )...
            );
        end

        function[hasObject,point]=readSignal(self)
            if~self.SensorSignalSubscriber.has_message()
                return;
            end
            signal=self.SensorSignalSubscriber.take();
            hasObject=signal.isHit;
            point=signal.impactPoint;
        end


        function actorType=getActorType(~)
            actorType=sim3d.utils.ActorTypes.RangeSensor;
        end
    end


    methods(Static)
        function sensorProperties=getRangeSensorProperties()
            sensorProperties=struct('Range',1,'HorizontalFOV',3.141592653589793,'VerticalFOV',3.141592653589793);
        end


        function tagName=getTagName()
            tagName='RangeSensor';
        end

    end
end
