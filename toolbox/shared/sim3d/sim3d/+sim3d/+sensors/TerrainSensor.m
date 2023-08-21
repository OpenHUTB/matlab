classdef TerrainSensor<sim3d.sensors.Sensor

    properties(Access=private)
        TerrainSensorConfigPublisher=[]
        TerrainSensorSignalSubscriber=[]
RayOrigins
RayDirections
RayLengths
NumberOfRays
        VisualizeRayTraceLines=true
        TerrainSensorProperties;
    end

    properties(Access=private,Constant=true)
        SuffixIn='/TerrainSensorDetection_IN';
        SuffixOut='/TerrainSensorConfiguration_OUT';
    end


    methods

        function self=TerrainSensor(sensorID,vehicleID,terrainSensorProperties,transform)
            sensorName=sim3d.sensors.Sensor.getSensorName('TerrainSensor',sensorID);
            self@sim3d.sensors.Sensor(sensorName,vehicleID,transform);
            self.RayOrigins=single(terrainSensorProperties.RayOrigins);
            self.RayDirections=single(terrainSensorProperties.RayDirections);
            self.RayLengths=single(terrainSensorProperties.RayLengths);
            self.NumberOfRays=uint32(length(terrainSensorProperties.RayLengths));
            self.VisualizeRayTraceLines=logical(terrainSensorProperties.VisualizeTraceLines);
            self.TerrainSensorProperties=terrainSensorProperties;
            self.validateInputSizes();
        end


        function setup(self)
            setup@sim3d.sensors.Sensor(self);
            self.TerrainSensorConfigPublisher=sim3d.io.Publisher([self.getTag(),sim3d.sensors.TerrainSensor.SuffixOut]);
            self.TerrainSensorSignalSubscriber=sim3d.io.Subscriber([self.getTag(),sim3d.sensors.TerrainSensor.SuffixIn]);
        end


        function reset(self)
            reset@sim3d.sensors.Sensor(self);
            self.TerrainSensorConfigPublisher.publish(self.TerrainSensorProperties);
        end
        function[hitLocations,isValidHit]=read(self)
            if self.TerrainSensorSignalSubscriber.has_message()
                terrainSensorDetections=self.TerrainSensorSignalSubscriber.take();
                hitLocations=terrainSensorDetections.HitLocations;
                isValidHit=terrainSensorDetections.IsValidHit;
            end
        end


        function delete(self)
            if~isempty(self.TerrainSensorConfigPublisher)
                self.TerrainSensorConfigPublisher.delete();
                self.TerrainSensorConfigPublisher=[];
            end
            if~isempty(self.TerrainSensorSignalSubscriber)
                self.TerrainSensorSignalSubscriber.delete();
                self.TerrainSensorSignalSubscriber=[];
            end
            delete@sim3d.sensors.Sensor(self);
        end
    end


    methods(Access=private)

        function outMatrix=formatMatrix(~,inMatrix,numRows,numColumns)
            outMatrix=reshape(inMatrix(1:numRows*numColumns),numColumns,numRows)';
        end


        function validateInputSizes(self)
            if(self.NumberOfRays<=0||size(self.RayOrigins,1)~=self.NumberOfRays||size(self.RayDirections,1)~=self.NumberOfRays||size(self.RayLengths,1)~=self.NumberOfRays)
                error('sim3d:RayTraceSensor:InvalidSize','Check sizes of Ray origins, Ray directions and Ray lengths to make sure they all correspond to equal and non-zero number of rays');
            end
            if(size(self.RayOrigins,2)~=3)
                error('sim3d:RayTraceSensor:InvalidSize','Ray origins must be of size [NumberOfRays, 3]');
            end

            if(size(self.RayDirections,2)~=3)
                error('sim3d:RayTraceSensor:InvalidSize','Ray directions must be of size [NumberOfRays, 3]');
            end

            if(size(self.RayLengths,2)~=1)
                error('sim3d:RayTraceSensor:InvalidSize','Ray lengths must be of size [NumberOfRays, 1]');
            end
        end
    end


    methods(Access=public,Hidden=true)

        function actorType=getActorType(~)
            actorType=sim3d.utils.ActorTypes.TerrainSensor;
        end
    end


    methods(Static)

        function sensorProperties=getTerrainSensorProperties()
            sensorProperties=struct(...
            'RayOrigins',zeros(10,3),...
            'RayDirections',ones(10,3),...
            'RayLengths',(ones(10,1)*10),...
            'VisualizeTraceLines',true...
            );
        end


        function tagName=getTagName()
            tagName='TerrainSensor';
        end
    end
end