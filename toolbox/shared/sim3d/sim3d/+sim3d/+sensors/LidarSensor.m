classdef LidarSensor<sim3d.sensors.Sensor







    properties(Access=private)
        LidarPublisher=[];
        LidarDataSubscriber=[];
        LidarSemanticSubscriber=[];
    end
    properties(Constant=true)
        SuffixOut='/Lidar_OUT';
        SuffixSignalIn='/LidarSignal_IN';
        SuffixSemanticSignalIn='/LidarSemanticSignal_IN';
        NumQuadrants=3;
    end
    properties(SetAccess=protected)
NumVertPoints
NumHorzPoints
QuadrantSize
Settings
    end

    methods
        function self=LidarSensor(sensorID,vehicleID,lidarProperties,transformProperties)
            sensorName=sim3d.sensors.Sensor.getSensorName('Lidar',sensorID);
            self@sim3d.sensors.Sensor(sensorName,vehicleID,transformProperties);

            validateattributes(lidarProperties.MaxRange,{'single'},{'<=',500,'nonnegative'});
            validateattributes(lidarProperties.VertFOV,{'single'},{'<=',90,'nonnegative'});
            validateattributes(lidarProperties.VertAngularResolution,{'single'},{'<=',10,'nonnegative'});
            validateattributes(lidarProperties.HorzFOV,{'single'},{'<=',360,'nonnegative'});
            validateattributes(lidarProperties.HorzAngularResolution,{'single'},{'<=',10,'nonnegative'});
            validateattributes(lidarProperties.RangeQuantizationFactor,{'numeric'},{'>=',lidarProperties.MaxRange/pow2(24)});
            validateattributes(transformProperties.getTranslation(),{'single'},{'size',[1,3]});
            validateattributes(transformProperties.getRotation(),{'single'},{'size',[1,3]});

            self.Settings.MaxRange=lidarProperties.MaxRange;
            self.Settings.VerticalFOV=lidarProperties.VertFOV;
            self.Settings.VerticalAngularResolution=lidarProperties.VertAngularResolution;
            self.Settings.HorizontalFOV=lidarProperties.HorzFOV/self.NumQuadrants;
            self.Settings.HorizontalAngularResolution=lidarProperties.HorzAngularResolution;
            self.Settings.RangeQuantizationFactor=lidarProperties.RangeQuantizationFactor;

            self.NumVertPoints=ceil(lidarProperties.VertFOV/lidarProperties.VertAngularResolution);
            self.NumHorzPoints=ceil(lidarProperties.HorzFOV/(sim3d.sensors.LidarSensor.NumQuadrants*lidarProperties.HorzAngularResolution));
            self.QuadrantSize=uint32(self.NumVertPoints*self.NumHorzPoints);
            self.NumHorzPoints=self.NumHorzPoints*sim3d.sensors.LidarSensor.NumQuadrants;
        end

        function setup(self)
            setup@sim3d.sensors.Sensor(self)

            self.LidarPublisher=sim3d.io.Publisher([self.getTag(),sim3d.sensors.LidarSensor.SuffixOut]);
            self.LidarDataSubscriber=sim3d.io.Subscriber([self.getTag(),sim3d.sensors.LidarSensor.SuffixSignalIn]);
            self.LidarSemanticSubscriber=sim3d.io.Subscriber([self.getTag(),sim3d.sensors.LidarSensor.SuffixSemanticSignalIn]);

            sim3d.engine.EngineReturnCode.assertObject(self.LidarPublisher);
            sim3d.engine.EngineReturnCode.assertObject(self.LidarDataSubscriber);
            sim3d.engine.EngineReturnCode.assertObject(self.LidarSemanticSubscriber);
        end

        function delete(self)
            if~isempty(self.LidarPublisher)
                self.LidarPublisher.delete();
                self.LidarPublisher=[];
            end

            if~isempty(self.LidarDataSubscriber)
                self.LidarDataSubscriber.delete();
                self.LidarDataSubscriber=[];
            end

            if~isempty(self.LidarSemanticSubscriber)
                self.LidarSemanticSubscriber.delete();
                self.LidarSemanticSubscriber=[];
            end

            delete@sim3d.sensors.Sensor(self);
        end

        function[range,reflectivity,semantic]=readSignal(self)
            sim3d.engine.EngineReturnCode.assertObject(self.LidarDataSubscriber);
            if self.LidarDataSubscriber.hasMessage()
                D123=self.LidarDataSubscriber.receive();
                [range1,reflect1]=decodeAndScaleData(self,D123(:,1));
                [range2,reflect2]=decodeAndScaleData(self,D123(:,2));
                [range3,reflect3]=decodeAndScaleData(self,D123(:,3));
                range=[range3;range1;range2];
                reflectivity=[reflect3;reflect1;reflect2];
                range=reshape(range,[self.NumVertPoints,self.NumHorzPoints]);
                reflectivity=reshape(reflectivity,[self.NumVertPoints,self.NumHorzPoints]);
            else
                range=[];
                reflectivity=[];
            end

            sim3d.engine.EngineReturnCode.assertObject(self.LidarSemanticSubscriber);
            if self.LidarSemanticSubscriber.hasMessage()
                semantic123=self.LidarSemanticSubscriber.receive();
                semantic=[uint8(semantic123(:,3));uint8(semantic123(:,1));uint8(semantic123(:,2))];
                semantic=reshape(uint8(semantic),[self.NumVertPoints,self.NumHorzPoints]);
            else
                semantic=[];
            end

        end

        function reset(self)
            reset@sim3d.sensors.Sensor(self);
            sim3d.engine.EngineReturnCode.assertObject(self.LidarPublisher);
            self.LidarPublisher.publish(self.Settings);
        end
    end


    methods(Static)
        function tagName=getTagName()
            tagName='Lidar';
        end
    end

    methods(Access=public,Hidden)
        function numVertPoints=getNumVertPoints(self)
            numVertPoints=self.NumVertPoints;
        end
        function numHorzPoints=getNumHorzPoints(self)
            numHorzPoints=self.NumHorzPoints;
        end

        function actorType=getActorType(~)
            actorType=sim3d.utils.ActorTypes.Lidar;
        end

    end

    methods(Access=protected)
        function[range,reflectivity]=decodeAndScaleData(self,D)


            noHitIndex=D(:)==0;
            reflectivity=single(bitshift(D,-24))/255.0;
            reflectivity(noHitIndex)=NaN;
            range=single(bitand(D,hex2dec('FFFFFF')))*self.Settings.RangeQuantizationFactor;
            range(noHitIndex)=NaN;
        end
    end
    methods(Static)
        function sensorProperties=getLidarSensorProperties()












            sensorProperties=struct('MaxRange',single(120),'VertFOV',single(40),...
            'VertAngularResolution',single(1.25),'HorzFOV',single(360),'HorzAngularResolution',single(0.16),...
            'RangeQuantizationFactor',single(0.002));
        end
    end
end

