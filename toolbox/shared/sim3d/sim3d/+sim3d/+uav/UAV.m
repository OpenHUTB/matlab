classdef(Hidden)UAV<sim3d.vehicle.Vehicle





    methods
        function self=UAV(actorName,actorID,translation,rotation,scale)



            mesh='';


            numberOfParts=uint32(1);
            self@sim3d.vehicle.Vehicle(actorName,actorID,translation,rotation,scale,numberOfParts,mesh);
        end

        function setup(self)

            setup@sim3d.vehicle.Vehicle(self);

        end

        function writeTransform(self,translation,rotation,scale)

            writeTransform@sim3d.vehicle.Vehicle(self,translation,rotation,scale);
        end

        function[translation,rotation,scale]=readTransform(self)
            [translation,rotation,scale]=readTransform@sim3d.vehicle.Vehicle(self);
        end
    end

end

