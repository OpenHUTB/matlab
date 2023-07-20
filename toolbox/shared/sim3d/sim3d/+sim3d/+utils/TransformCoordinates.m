classdef TransformCoordinates



    methods(Static)
        function coords=transfrom_UE_to_sim3d(coords)
            coords(2)=-coords(2);
        end
        function coords=transform_sim3d_to_UE(coords)
            coords(2)=-coords(2);
        end
    end
end

