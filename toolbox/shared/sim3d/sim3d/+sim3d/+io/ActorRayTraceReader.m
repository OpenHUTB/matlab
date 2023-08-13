classdef ActorRayTraceReader<handle

    properties
        Subscriber=[];
        NumberOfRays=1;
        traceStart=[];
        traceEnd=[];
    end
    properties(Constant=true)
        Suffix='/TerrainSensorDetection_IN';
    end
    methods
        function self=ActorRayTraceReader(actorTag,numberOfRays)
            self.Subscriber=sim3d.io.Subscriber([actorTag,self.Suffix]);
            self.NumberOfRays=numberOfRays;
            if isempty(self.Subscriber)||self.Subscriber==uint64(0)
                timeoutException=MException('sim3d:ActorRayTraceReader:ActorRayTraceReader:SetupError',...
                '3D Simulation engine interface reader setup error. Is the 3D Simulation engine running?');
                throw(timeoutException);
            end
        end

        function delete(self)
            if~isempty(self.Subscriber)&&self.Subscriber~=uint64(0)
                self.Subscriber=[];
            end
        end

        function[traceStart,traceEnd]=read(self)
            sim3d.engine.EngineReturnCode.assertObject(self.Subscriber);
            traceStart=[];
            traceEnd=[];
            if self.Subscriber.has_message()
                terrainSensorDetections=self.Subscriber.take();
                traceStart=terrainSensorDetections.TraceStart;
                traceEnd=terrainSensorDetections.TraceEnd;
            end
        end
    end
end