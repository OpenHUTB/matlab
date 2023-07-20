classdef(Hidden)Sensor<sim3d.AbstractActor


























    properties(Access=private)
        GroundTruthSubscriber=[];
    end

    properties(Constant=true,Access=public,Hidden=true)
        GroundTruth='/GroundTruth_IN';
    end

    properties(Dependent,SetAccess='protected',GetAccess='public',Hidden=false)

SensorIdentifier
    end

    properties(Dependent,SetAccess='protected',GetAccess='public',Hidden=true)

VehicleIdentifier
    end

    methods
        function self=Sensor(sensorID,vehicleID,transform)
            sensorName=sim3d.sensors.Sensor.getSensorName('Sim3dSensor',sensorID);
            self@sim3d.AbstractActor(sensorName,vehicleID,transform.getTranslation(),deg2rad(transform.getRotation()),transform.getScale());
        end

        function setup(self)
            setup@sim3d.AbstractActor(self)
            self.GroundTruthSubscriber=sim3d.io.Subscriber([self.getTag(),sim3d.sensors.LidarSensor.GroundTruth]);
        end

        function delete(self)
            if~isempty(self.GroundTruthSubscriber)
                self.GroundTruthSubscriber.delete();
                self.GroundTruthSubscriber=[];
            end
            delete@sim3d.AbstractActor(self);
        end

        function SensorIdentifier=get.SensorIdentifier(self)
            SensorIdentifier=self.ObjectIdentifier;
        end

        function VehicleIdentifier=get.VehicleIdentifier(self)
            VehicleIdentifier=self.getParentIdentifier();
        end

        function[groundTruth]=readGroundTruth(self)
            if~isempty(self.GroundTruthSubscriber)&&self.GroundTruthSubscriber.hasMessage()
                groundTruth=self.GroundTruthSubscriber.receive();
            else
                [groundTruth.Translation,groundTruth.Rotation,~]=self.readTransform();
            end

            groundTruthTransform=sim3d.utils.Transform(groundTruth.Translation,groundTruth.Rotation);
            groundTruthTransformISO8855=sim3d.utils.TransformISO8855([0,0,0],[0,0,0],[1,1,1],...
            {sim3d.units.si.M(),sim3d.units.si.Rad(),sim3d.units.One()});
            groundTruthTransformISO8855.copy(groundTruthTransform);
            [groundTruth.Translation,groundTruth.Rotation]=groundTruthTransformISO8855.get();
        end
    end

    methods(Access=public,Hidden=true)
        function tag=getParentTag(self)
            tag=self.VehicleIdentifier;
        end
    end

    methods(Static)
        function tagName=getTagName()
            tagName='Sim3dSensor';
        end

        function sensorName=getSensorName(sensorTag,sensorID)
            if isnumeric(sensorID)
                sensorName=[sensorTag,num2str(sensorID)];
            else
                sensorName=sensorID;
            end
        end

    end

end

