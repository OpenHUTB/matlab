classdef ClientEventData<event.EventData
    properties
        ClientName;
    end
    methods
        function this=ClientEventData(name)
            this.ClientName=name;
        end
    end
end