classdef ActorRayTraceWriter<handle




    properties
        Publisher=[];
        RayConfig;
    end
    properties(Constant=true)
        Suffix='/TerrainSensorConfiguration_OUT';
    end
    methods
        function self=ActorRayTraceWriter(actorTag,numberOfRays)
            self.Publisher=sim3d.io.Publisher([actorTag,self.Suffix]);
            if isempty(self.Publisher)||self.Publisher==uint64(0)
                timeoutException=MException('sim3d:ActorRayTraceWriter:ActorRayTraceWriter:SetupError',...
                '3D Simulation engine interface writer setup error. Is the 3D Simulation engine running?');
                throw(timeoutException);
            end
        end

        function delete(self)
            if~isempty(self.Publisher)&&self.Publisher~=uint64(0)
                self.Publisher=[];
            end
        end

        function write(self,traceStart,traceEnd)
            sim3d.engine.EngineReturnCode.assertObject(self.Publisher);
            self.RayConfig.RayStart=double(traceStart);
            self.RayConfig.RayEnd=double(traceEnd);
            self.Publisher.publish(self.RayConfig);
        end
    end
end
