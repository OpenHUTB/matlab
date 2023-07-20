
classdef(ConstructOnLoad)EventData<event.EventData
    properties
Data
    end

    methods
        function obj=EventData(eventData)
            obj.Data=eventData;
        end
    end
end