classdef(ConstructOnLoad)DataLoadedEventData<event.EventData



    properties
LoadedData
    end

    methods
        function eventData=DataLoadedEventData(data)
            eventData.LoadedData=data;
        end
    end
end

