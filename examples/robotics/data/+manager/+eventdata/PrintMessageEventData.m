classdef(ConstructOnLoad)PrintMessageEventData<event.EventData



    properties
Message
Color
    end

    methods
        function eventData=PrintMessageEventData(msg,color)
            eventData.Message=msg;
            eventData.Color=color;
        end
    end
end

