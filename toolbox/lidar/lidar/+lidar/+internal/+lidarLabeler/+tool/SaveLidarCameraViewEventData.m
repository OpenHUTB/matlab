classdef SaveLidarCameraViewEventData<event.EventData








    properties
Operation



Index
    end

    methods
        function eventData=SaveLidarCameraViewEventData(index,operation)
            eventData.Index=index;
            eventData.Operation=operation;
        end
    end
end