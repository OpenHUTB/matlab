classdef CloseEventData<event.EventData
    properties
        AllFilesSaved logical
    end

    methods
        function data=CloseEventData(newState)
            data.AllFilesSaved=newState;
        end
    end
end
