classdef(ConstructOnLoad)SlddFileSelectedEventData<event.EventData
    properties
        FileName=''
    end
    methods
        function eventData=SlddFileSelectedEventData(value)
            eventData.FileName=value;
        end
    end
end