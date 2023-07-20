classdef LidarLimitsEventData<event.EventData




    properties
LimitsData
XMinLimits
XMaxLimits
YMinLimits
YMaxLimits
ZMinLimits
ZMaxLimits
PointDimension

    end

    methods
        function eventData=LidarLimitsEventData(limits,xmin,xmax,ymin,ymax,zmin,...
            zmax,pointSize)
            eventData.LimitsData=limits;
            eventData.XMinLimits=xmin;
            eventData.XMaxLimits=xmax;
            eventData.YMinLimits=ymin;
            eventData.YMaxLimits=ymax;
            eventData.ZMinLimits=zmin;
            eventData.ZMaxLimits=zmax;
            eventData.PointDimension=pointSize;
        end
    end
end