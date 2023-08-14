classdef(ConstructOnLoad)CameraMovedEventData<event.EventData




    properties

CameraPosition
CameraTarget
CameraUpVector
CameraZoom

PreviousCameraPosition
PreviousCameraTarget
PreviousCameraUpVector
PreviousCameraZoom

    end

    methods

        function evt=CameraMovedEventData(pos,target,upv,zoom,oldpos,oldtarget,oldupv,oldzoom)

            evt.CameraPosition=pos;
            evt.CameraTarget=target;
            evt.CameraUpVector=upv;
            evt.CameraZoom=zoom;

            evt.PreviousCameraPosition=oldpos;
            evt.PreviousCameraTarget=oldtarget;
            evt.PreviousCameraUpVector=oldupv;
            evt.PreviousCameraZoom=oldzoom;

        end

    end

end