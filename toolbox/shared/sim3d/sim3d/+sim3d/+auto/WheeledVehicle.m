classdef WheeledVehicle<sim3d.vehicle.Vehicle

    properties(SetAccess='public',GetAccess='public')
        DebugRayTrace;
    end
    properties(Access=protected)
        TerrainSensorPublisher=[];
        TerrainSensorSubscriber=[];
        TerrainSensorConfig;
        RayStart;
        RayEnd;
        RayTraceMaxValueLimit=1.0e+10;
    end

    properties(Access=private,Constant=true)
        TerrainSensorSuffixOut='/TerrainSensorConfiguration_OUT';
        TerrainSensorSuffixIn='/TerrainSensorDetection_IN';
    end

    methods




        function self=WheeledVehicle(actorName,actorID,translation,rotation,scale,numberOfParts,mesh)
            self@sim3d.vehicle.Vehicle(actorName,actorID,translation,rotation,scale,numberOfParts,mesh);

        end

        function setup(self)
            setup@sim3d.vehicle.Vehicle(self);
            self.TerrainSensorConfig.RayStart=self.RayStart;
            self.TerrainSensorConfig.RayEnd=self.RayEnd;
            self.TerrainSensorPublisher=sim3d.io.Publisher([self.ActorName,self.TerrainSensorSuffixOut]);
            self.TerrainSensorSubscriber=sim3d.io.Subscriber([self.ActorName,self.TerrainSensorSuffixIn]);
            self.TerrainSensorPublisher.publish(self.TerrainSensorConfig);
        end

        function writeTransform(self,translation,rotation,scale)
            writeTransform@sim3d.vehicle.Vehicle(self,translation,rotation,scale);
        end

        function[translation,rotation,scale]=readTransform(self)
            [translation,rotation,scale]=readTransform@sim3d.vehicle.Vehicle(self);
        end
        function delete(self)
            delete@sim3d.vehicle.Vehicle(self);
            if~isempty(self.TerrainSensorPublisher)
                self.TerrainSensorPublisher=[];
            end
            if~isempty(self.TerrainSensorSubscriber)
                self.TerrainSensorSubscriber=[];
            end
        end
    end

    methods(Access=protected,Static)
        function VerifyInitialTransformSize(translation,rotation,scale,numberOfParts)


            if(~(all(size(translation)==[numberOfParts,3])&&all(size(rotation)==[numberOfParts,3])&&all(size(scale)==[numberOfParts,3])))
                error('sim3d:invalidInitialTransform','Incorrect size for initial Translation/Rotation. Make sure size of initial Translation/Rotation matched with corresponding Dolly type.');
            end
        end
    end
end


