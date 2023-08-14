classdef(ConstructOnLoad)CameraPositionChangeEventData<event.EventData
    properties
CameraPosition
CameraUpVector
CameraTarget
CameraViewAngle
    end

    methods
        function data=CameraPositionChangeEventData(position,upVector,target,ang)
            data.CameraPosition=position;
            data.CameraUpVector=upVector;
            data.CameraTarget=target;
            data.CameraViewAngle=ang;
        end
    end
end