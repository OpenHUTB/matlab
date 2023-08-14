classdef(ConstructOnLoad)ValidationEventData<event.EventData





    properties
State
Type
Message
    end

    methods
        function eventObj=ValidationEventData(State,type,Message)
            eventObj.State=State;
            eventObj.Type=type;
            eventObj.Message=Message;
        end

    end
end

