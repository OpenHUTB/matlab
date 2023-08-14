classdef(ConstructOnLoad)EventData<event.EventData

    properties
Data
    end

    methods
        function eventData=EventData(data)
            eventData.Data=data;
        end
    end
end