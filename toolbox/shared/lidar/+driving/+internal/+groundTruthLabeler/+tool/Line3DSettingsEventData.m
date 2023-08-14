classdef(ConstructOnLoad)Line3DSettingsEventData<event.EventData



    properties
SnapToPoint
    end

    methods
        function eventData=Line3DSettingsEventData(tf)
            eventData.SnapToPoint=tf;
        end
    end
end
