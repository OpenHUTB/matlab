classdef(ConstructOnLoad)ValueChangedEventData<event.EventData





    properties
Data
    end

    methods
        function eventObj=ValueChangedEventData(Data)
            eventObj.Data=Data;
        end

    end
end
