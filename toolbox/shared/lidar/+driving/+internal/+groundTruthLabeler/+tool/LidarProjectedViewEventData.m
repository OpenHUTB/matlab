classdef LidarProjectedViewEventData<event.EventData



    properties
Status
    end

    methods
        function eventData=LidarProjectedViewEventData(status)
            eventData.Status=status;
        end
    end
end