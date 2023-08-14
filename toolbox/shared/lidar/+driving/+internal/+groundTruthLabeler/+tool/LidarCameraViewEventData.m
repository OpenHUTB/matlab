classdef(ConstructOnLoad)LidarCameraViewEventData<event.EventData



    properties
CameraPosition
CameraTarget
CameraUpVector
CameraViewAngle
AzimuthElevation
    end

    methods
        function eventData=LidarCameraViewEventData(pos,tg,up,ang,az)
            eventData.CameraPosition=pos;
            eventData.CameraTarget=tg;
            eventData.CameraUpVector=up;
            eventData.CameraViewAngle=ang;
            eventData.AzimuthElevation=az;
        end
    end
end