classdef(ConstructOnLoad)EventData<event.EventData




    properties
Data
    end

    methods(Hidden)
        function eventData=EventData(data)
            eventData.Data=data;
        end
    end
end
