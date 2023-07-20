
classdef DisplayFactory<handle

    properties

    end

    methods(Static)
        function display=createDisplay(hFig,dispType,toolType,name)
            if(dispType==displayType.None)
                display=vision.internal.labeler.tool.display.NoneDisplay(hFig,toolType,name);
            elseif(dispType==displayType.Image)
                display=vision.internal.labeler.tool.display.VideoDisplay(hFig,name);
            elseif(dispType==displayType.ImageMixedSize)
                display=vision.internal.labeler.tool.display.ImageDisplay(hFig,name);
            elseif(dispType==displayType.BlockedImageMixedSize)
                display=vision.internal.labeler.tool.display.BlockedImageDisplay(hFig,name);
            elseif(dispType==displayType.PointCloud&&...
                toolType==vision.internal.toolType.LidarLabeler)
                display=lidar.internal.labeler.tool.display.LidarDisplay(hFig,name);
            elseif(dispType==displayType.PointCloud)
                display=vision.internal.labeler.tool.display.PointCloudDisplay(hFig,name);
            else
                display=[];
            end
        end
    end
end
