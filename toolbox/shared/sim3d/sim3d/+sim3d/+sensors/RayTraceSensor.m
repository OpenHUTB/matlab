classdef RayTraceSensor<sim3d.sensors.Sensor


    properties(Access=private)
        RaytraceConfigPublisher=[];
        RaytraceSignalSubscriber=[];
        RaytraceSensorProperties;
        NumberOfRays;
        MaxNumberOfHits;
    end

    properties(Access=private,Constant=true)
        SuffixIn='/RayTraceSignal_IN';
        SuffixOut='/RayTraceConfiguration_OUT';
    end
    methods
        function self=RayTraceSensor(sensorID,vehicleID,rayTraceSensorProperties,transform)
            sensorName=sim3d.sensors.Sensor.getSensorName('RayTraceSensor',sensorID);
            self@sim3d.sensors.Sensor(sensorName,vehicleID,transform);
            self.RaytraceSensorProperties.RayOrigins=double(rayTraceSensorProperties.RayOrigins);
            self.RaytraceSensorProperties.RayDirections=double(rayTraceSensorProperties.RayDirections);
            self.RaytraceSensorProperties.RayLengths=double(rayTraceSensorProperties.RayLengths);
            self.RaytraceSensorProperties.NumberOfBounces=uint32(rayTraceSensorProperties.NumberOfBounces);
            self.RaytraceSensorProperties.VisualizeTraceLines=logical(rayTraceSensorProperties.VisualizeTraceLines);
            self.RaytraceSensorProperties.EnableOptimization=logical(rayTraceSensorProperties.EnableOptimization);
            self.RaytraceSensorProperties.TargetActorTags=rayTraceSensorProperties.TargetActorTags;
            self.NumberOfRays=uint32(length(rayTraceSensorProperties.RayLengths));
            self.MaxNumberOfHits=self.NumberOfRays*(self.RaytraceSensorProperties.NumberOfBounces+1);
            self.validateInputSizes();

        end
        function setup(self)
            setup@sim3d.sensors.Sensor(self);
            payloadSize=liveio.ArrayPacketSize(self.RaytraceSensorProperties);
            self.RaytraceConfigPublisher=sim3d.io.Publisher([self.getTag(),sim3d.sensors.RayTraceSensor.SuffixOut],'PacketSize',payloadSize);
            self.RaytraceSignalSubscriber=sim3d.io.Subscriber([self.getTag(),sim3d.sensors.RayTraceSensor.SuffixIn]);
        end
        function reset(self)
            self.RaytraceConfigPublisher.publish(self.RaytraceSensorProperties);
        end
        function[surfaceIds,hitDistances,hitLocations,hitNormals,validHits]=read(self)
            hitLocations=single(zeros(self.MaxNumberOfHits,3));
            hitNormals=single(zeros(self.MaxNumberOfHits,3));
            hitDistances=single(zeros(self.MaxNumberOfHits,1));
            surfaceIds=uint32(zeros(self.MaxNumberOfHits,1));
            validHits=logical(zeros(self.MaxNumberOfHits,1));
            if self.RaytraceSignalSubscriber.has_message()
                raytraceSensorDetections=self.RaytraceSignalSubscriber.take();
                hitLocations=single(raytraceSensorDetections.HitLocations);
                hitNormals=single(raytraceSensorDetections.HitNormals);
                hitDistances=single(raytraceSensorDetections.HitDistances);
                surfaceIds=raytraceSensorDetections.SurfaceIds;
                validHits=raytraceSensorDetections.IsValidHit;
            end
        end
        function delete(self)
            if~isempty(self.RaytraceConfigPublisher)
                self.RaytraceConfigPublisher=[];
            end

            if~isempty(self.RaytraceSignalSubscriber)
                self.RaytraceSignalSubscriber=[];
            end

            delete@sim3d.sensors.Sensor(self);
        end
    end
    methods(Access=private)
        function outMatrix=formatMatrix(~,inMatrix,numRows,numColumns)
            outMatrix=reshape(inMatrix(1:numRows*numColumns),numColumns,numRows)';
        end
        function validateInputSizes(self)
            if(self.NumberOfRays<=0||size(self.RaytraceSensorProperties.RayOrigins,1)~=self.NumberOfRays||size(self.RaytraceSensorProperties.RayDirections,1)~=self.NumberOfRays||size(self.RaytraceSensorProperties.RayLengths,1)~=self.NumberOfRays)
                error('sim3d:RayTraceSensor:InvalidSize','Check sizes of Ray origins, Ray directions and Ray lengths to make sure they all correspond to equal and non-zero number of rays');
            end
            if(size(self.RaytraceSensorProperties.RayOrigins,2)~=3)
                error('sim3d:RayTraceSensor:InvalidSize','Ray origins must be of size [NumberOfRays, 3]');
            end

            if(size(self.RaytraceSensorProperties.RayDirections,2)~=3)
                error('sim3d:RayTraceSensor:InvalidSize','Ray directions must be of size [NumberOfRays, 3]');
            end

            if(size(self.RaytraceSensorProperties.RayLengths,2)~=1)
                error('sim3d:RayTraceSensor:InvalidSize','Ray lengths must be of size [NumberOfRays, 1]');
            end
        end
    end
    methods(Access=public,Hidden=true)
        function actorType=getActorType(~)
            actorType=sim3d.utils.ActorTypes.RayTraceSensor;
        end
    end
    methods(Static)
        function sensorProperties=getRayTraceSensorProperties()



            sensorProperties=struct('RayOrigins',zeros(10,3),...
            'RayDirections',ones(10,3),...
            'RayLengths',(ones(10,1)*10),...
            'NumberOfBounces',2,...
            'VisualizeTraceLines',true,...
            'EnableOptimization',false,...
            'TargetActorTags',[""]);
        end

        function tagName=getTagName()
            tagName='RayTraceSensor';
        end
    end
end