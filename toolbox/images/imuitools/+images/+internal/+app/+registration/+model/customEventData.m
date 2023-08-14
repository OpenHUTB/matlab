classdef(ConstructOnLoad)customEventData<event.EventData



    properties
data
    end

    methods
        function eventData=customEventData(newData)
            eventData.data=newData;
        end
    end
end