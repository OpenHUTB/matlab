classdef CuboidLabeler<lidar.internal.labeler.tool.CuboidLabeler





    methods

        function this=CuboidLabeler()
            this@lidar.internal.labeler.tool.CuboidLabeler();
        end

        function doAutoAlign(this,enhancedCuboidRoi,x,y,z)
            autoAlign(this,enhancedCuboidRoi,x,y,z);
        end

    end

    methods(Access=protected)

        function autoAlign(this,enhancedCuboidRoi,x,y,z)
            if this.UsePCFit
                TF=inROI(enhancedCuboidRoi,x,y,z);

                if sum(TF)>3

                    [cuboid,model]=this.getOrientedBox(enhancedCuboidRoi,...
                    TF,x,y,z);

                    set(enhancedCuboidRoi,'RotationAngle',model.Orientation);

                    set(enhancedCuboidRoi,'Position',cuboid(1:6));
                end
            end
        end
    end
end
